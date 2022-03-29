Gem::Specification.new do |s|
  s.name        = 'responsive-images-for-jekyll'
  s.version     = '0.3.1'
  s.date        = '2022-03-05'
  s.summary     = 'Creates responsive and optimized images for Jekyll!'
  s.description = ''
  s.authors     = ['Cyrill Püntener']
  s.files       = ['lib/responsive-images-for-jekyll.rb']

  s.add_dependency 'jekyll', '> 3.3', '< 5.0'
  s.add_dependency 'mini_magick', '~> 4.8'
  s.add_dependency  'rmagick', '~> 4.2.4'
  s.add_dependency  'victor', '~> 0.3.3'
  s.add_dependency 'image_optim', '~> 0.31.1'
  s.add_dependency 'image_optim_pack', '~> 0.8.0.20220131'
end