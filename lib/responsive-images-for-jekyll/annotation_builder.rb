module AnnotationBuilder

  #
  # Helper function which estimates the with of a string.
  # Uses the Ubuntu font in bold letters
  #
  def _estimate_str_width(str, font_size)

    label = Magick::Draw.new
    label.font = "Ubuntu"
    label.font_size(font_size)
    label.text_antialias(true)
    label.font_style = Magick::NormalStyle
    label.font_weight = Magick::BoldWeight
    label.gravity = Magick::CenterGravity
    label.text(0, 0, str)
    metrics = label.get_type_metrics(str)
    width = metrics.width

    # correction constant
    width * 2.68

  end

  #
  # Creates an SVG graphic of size img_dim.
  # You can customize the code in this function to change the SVG annotation.
  #
  #
  def create_svg(img_desc, svg_file_path, img_dim)

    dim = img_dim.split('x')

    svg_w = dim[0].to_i
    svg_h = dim[1].to_i

    claim_font_size = 30
    claim_v_border = 16
    claim_h_border = 16

    claim_space = claim_v_border / 2
    arrow_height = claim_v_border
    arrow_width = 1.25 * arrow_height

    arrow_position_x = svg_w - 100 - _estimate_str_width(img_desc.split.last, claim_font_size) - claim_h_border - arrow_width / 2

    claim_width = [_estimate_str_width("Cevi Züri 11", claim_font_size) + 2 * claim_h_border, svg_w - 125 - arrow_position_x + 3 * claim_h_border].max
    claim2_width = _estimate_str_width(img_desc, claim_font_size) + 2 * claim_h_border

    height_to_font_size_factor = 0.75
    claim_height = claim_font_size * height_to_font_size_factor + 2 * claim_v_border

    svg = Victor::SVG.new width: svg_w, height: svg_h

    # We only want to annotate images with a width of exactly 1800 pixels.
    # For all other images we create an empty SVG graphic!
    if svg_w == 1125
      svg.build do
        svg.css = {
          '*': {
            stroke_width: 0
          }
        }
        polygon points: %W[#{svg_w - 100},#{svg_h - 100 - claim_height - claim_space} #{arrow_position_x + arrow_width / 2 },#{svg_h - 100 - claim_height - claim_space}  #{arrow_position_x},#{svg_h - 100 - claim_height - claim_space - arrow_height}  #{arrow_position_x - arrow_width / 2},#{svg_h - 100 - claim_height - claim_space}  #{svg_w - claim2_width - 100},#{svg_h - 100 - claim_height - claim_space}  #{svg_w - claim2_width - 100},#{svg_h - 100 - 2 * claim_height - claim_space} #{svg_w - 100},#{svg_h - 100 - 2 * claim_height - claim_space}], fill: '#ffffff', style: { stroke: '#ffffff' }
        polygon points: %W[#{svg_w - 125},#{svg_h - 100} #{svg_w - 125 - claim_width},#{svg_h - 100} #{svg_w - 125 - claim_width},#{svg_h - 100 - claim_height} #{arrow_position_x - arrow_width / 2},#{svg_h - 100 - claim_height} #{arrow_position_x},#{svg_h - 100 - claim_height - arrow_height} #{arrow_position_x + arrow_width / 2},#{svg_h - 100 - claim_height} #{svg_w - 125},#{svg_h - 100 - claim_height}], fill: '#ffffff', style: { stroke: '#ffffff' }
        svg.text "Cevi Züri 11", text_anchor: :center, x: svg_w - 125 - claim_width / 2, y: svg_h - 100 - claim_v_border, font_weight: 'bold', font_family: 'Ubuntu', font_size: claim_font_size, fill: :"#585858", style: { stroke: '#585858' }
        svg.text img_desc, text_anchor: :center, x: svg_w - 100 - claim2_width / 2, y: svg_h - 100 - claim_v_border - claim_height - claim_space, font_weight: 'bold', font_family: 'Ubuntu', font_size: claim_font_size, fill: :"#585858", style: { stroke: '#585858' }
      end

    end

    svg.save svg_file_path

  end

end
