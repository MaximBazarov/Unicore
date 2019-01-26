Pod::Spec.new do |s|

  s.name = 'Unicore'
  s.version = '1.0.4'
  s.swift_version = '4.2'
  s.license = 'MIT'
  s.summary = 'The Unicore is an application design approach which lets you increase the reliability of an application, increase testability, and give your team the flexibility by decoupling code of an application. It is a convenient combination of the data-driven and redux.js ideas. The framework itself provides you with a convenient way to apply this approach to your app.'
  s.homepage = 'https://github.com/Unicore/Unicore'
  s.authors = { 'Maxim Bazarov' => 'bazaroffma@gmail.com' }
  s.source = { :git => 'https://github.com/Unicore/Unicore.git', :tag => s.version }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.source_files = 'Source/**/*.swift'

end
