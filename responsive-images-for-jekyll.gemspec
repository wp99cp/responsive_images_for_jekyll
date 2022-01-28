Gem::Specification.new do |s|
  s.name        = 'responsive-images-for-jekyll'
  s.version     = '0.1.1'
  s.date        = '2022-01-28'
  s.summary     = 'Creates responsive and optimized images for Jekyll!'
  s.description = ''
  s.authors     = ['Cyrill Püntener']
  s.files       = %w[lib/pre-processor.rb lib/image-optimizer.rb]

  s.add_dependency 'jekyll', '> 3.3', '< 5.0'
  s.add_dependency 'mini_magick', '~> 4.8'
  s.add_dependency 'image_optim'
  s.add_dependency 'image_optim_pack'
end