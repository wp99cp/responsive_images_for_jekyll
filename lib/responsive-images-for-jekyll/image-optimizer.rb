require_relative 'annotation_builder.rb'

require 'digest/sha1'

require 'yaml'
require "image_optim"
require "image_optim_pack"

require "mini_magick"
require "RMagick"
require 'victor'

module Jekyll
  class ImageInlineTag < Liquid::Tag

    # Include the module of the AnnotationBuilder

    CACHE_DIR = "imgs/"
    HASH_LENGTH = 8

    def initialize(tag_name, input, tokens)
      super
      @input = input

      imageoptim_options = YAML::load_file "_config.yml"
      @imageoptim_options = imageoptim_options["imageoptim"] || {}

      @image_optim = ImageOptim.new @imageoptim_options

    end

    # Generate output image filename.
    def _dest_filename(src_path, options, img_desc)

      hash = Digest::SHA1.hexdigest(img_desc)
      short_hash = hash[0, HASH_LENGTH]
      options_slug = options.gsub(/[^\da-z]+/i, "")
      ext = File.extname(src_path)

      if img_desc == ''
        "#{File.basename(src_path, ".*")}_#{options_slug}#{ext}"
      else
        "#{File.basename(src_path, ".*")}_#{options_slug}_#{short_hash}#{ext}"
      end
    end

    # Build the path strings.
    def _paths(repo_base, img_path, options, img_desc)

      src_path = File.join(repo_base, img_path)
      raise "Image at #{src_path} is not readable" unless File.readable?(src_path)

      dest_dir = File.join(repo_base, CACHE_DIR)

      dest_filename = _dest_filename(src_path, options, img_desc)

      dest_path = File.join(dest_dir, dest_filename)
      dest_path_rel = File.join(CACHE_DIR, dest_filename)

      return src_path, dest_path, dest_dir, dest_filename, dest_path_rel
    end

    # Determine whether the image needs to be written.
    def _must_create?(src_path, dest_path)
      !File.exist?(dest_path) || File.mtime(dest_path) <= File.mtime(src_path)
    end

    # Read, process, and write out as new image.
    def _process_img(src_path, options, dest_path)
    #
    # Annotate the image with a custom SVG graphic.
    # The graphic can be created on the fly using the img_desc
    #
    # param dest_path: e.g. "my-image_800x800_lka34jks.jpg"
    # param img_desc: e.g. "This is a cat!"
    # param img_dim: e.g. "800x800"
    #
    def annotate_image(dest_path, img_desc, img_dim)

      annotation_file_name = 'imgs/annotation.svg'

      # Load Annotation SVG from the annotation_file_name
      svg_logo = Magick::ImageList.new(annotation_file_name) do |c|
        c.background_color = "Transparent"
      end

      image = Magick::ImageList.new(dest_path)
      image.gravity = Magick::EastGravity

      composed_image = image.composite_layers(svg_logo, Magick::LightenCompositeOp)
      composed_image = composed_image.composite_layers(svg_logo, Magick::MultiplyCompositeOp)

      composed_image.format = 'jpg'
      composed_image.write dest_path

    end

    # Processes the image: Annotate with custom graphic and shrink to the specified img_size
    #
    # param source: e.g. "my-image.jpg"
    # param img_dim: e.g. "800x800"
    # param dest_path: e.g. "my-image_800x800_lka34jks.jpg"
    # param img_desc: e.g. "This is a cat!"
    #
    def _process_img(src_path, img_dim, dest_path, img_desc)
      image = MiniMagick::Image.open(src_path)

      image.strip
      image.resize img_dim
      image.write dest_path

      optimize(dest_path)

      if img_desc != ''
        annotate_image(dest_path, img_desc, img_dim)
      end

    end

    def optimize(image)
      puts "Optimizing #{image}".green
      @image_optim.optimize_image! image
    end

    #
    # param source: e.g. "my-image.jpg"
    # param options: e.g. "800x800>"
    # param img_desc: e.g. "800x800>"
    #
    # return dest_path_rel: Relative path for output file.
    def resize(img_src, options, img_desc)
      raise "`source` must be a string - got: #{img_src.class}" unless img_src.is_a? String
      raise "`source` may not be empty" unless img_src.length > 0
      raise "`options` must be a string - got: #{options.class}" unless options.is_a? String
      raise "`options` may not be empty" unless options.length > 0

      site = @context.registers[:site]

      src_path, dest_path, dest_dir, dest_filename, dest_path_rel = _paths(site.source, img_src, options, img_desc)

      FileUtils.mkdir_p(dest_dir)

      if _must_create?(src_path, dest_path)
        puts "Resizing '#{img_src}' to '#{dest_path_rel}' - using options: '#{options}'"

        _process_img(src_path, options, dest_path, img_desc)

        site.static_files << Jekyll::StaticFile.new(site, site.source, CACHE_DIR, dest_filename)
      end

      File.join(site.baseurl, dest_path_rel)
    end

    def split_params(params)
      params.split("::").map(&:strip)
    end

    #
    # This function creates an HTML snipped rendering the image inside a figure tag.
    # As input it gets the liquid context of the current image, containing the
    # img_src path and the img_desc (description).
    #
    # It then optimizes the image (i.g. creating different size versions) and annotate the
    # image with a custom graphic (e.g. render the image description into the image).
    #
    def render(context)

      args = split_params(@input)
      raise "Wrong number of arguments" unless args.length == 3

      @context = context
      img_src = args[0]
      img_desc = args[1]

      path_1800x1200 = resize(img_src, '1800x1200', img_desc)
      path_1200x800 = resize(img_src, '1200x800', img_desc)
      path_1125x750 = resize(img_src, '1125x750', img_desc)
      path_600x400 = resize(img_src, '600x400', img_desc)
      path_450x300 = resize(img_src, '450x300', img_desc)

      # Write the output HTML string
      output = "<figure class=\"image_figure\">
                  <img src=\"#{ path_1800x1200 }\" alt=\"#{ img_desc }\"
                       srcset=\" #{path_1800x1200} 1800w, #{path_1200x800} 1200w,
                                 #{path_1125x750} 1125w,  #{path_600x400} 600w,
                                 #{path_450x300} 450w \"/>
                  <span class=\"image_description\"> #{ img_desc } </span>
                </figure>"

      # Render it on the page by returning it
      output

    end
  end
end

Liquid::Template.register_tag('image', Jekyll::ImageInlineTag)