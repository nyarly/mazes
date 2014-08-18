Gem::Specification.new do |spec|
  spec.name		= "html_mazes"
  spec.version		= "0.0.1"
  author_list = {
    "Judson Lester" => 'nyarly@gmail.com'
  }
  spec.authors		= author_list.keys
  spec.email		= spec.authors.map {|name| author_list[name]}
  spec.summary		= "3d mazes in the browser"
  spec.description	= <<-EndDescription
  html_mazes
  open link in browser
  get lost
  EndDescription

  spec.rubyforge_project= spec.name.downcase
  spec.homepage        = "http://git.lrdesign.com/judson/mazes"
  spec.required_rubygems_version = Gem::Requirement.new(">= 0") if spec.respond_to? :required_rubygems_version=

  # Do this: y$@"
  # !!find lib bin doc spec spec_help -not -regex '.*\.sw.' -type f 2>/dev/null
  spec.files		= %w[
    lib/html_maze/cli.rb
    lib/html_maze/web_app.rb
    lib/html_maze/mazes.rb
    bin/html_maze
  ]

  spec.licenses = ["MIT"]
  spec.require_paths = %w[lib/]
  spec.rubygems_version = "1.3.5"

  spec.has_rdoc		= true
  spec.extra_rdoc_files = Dir.glob("doc/**/*")
  spec.rdoc_options	= %w{--inline-source }
  spec.rdoc_options	+= %w{--main doc/README }
  spec.rdoc_options	+= ["--title", "#{spec.name}-#{spec.version} Documentation"]

  spec.add_dependency("thin", "> 0")
  spec.add_dependency("rack", "> 0")
  spec.add_dependency("sass", "> 0")
  spec.add_dependency("compass-core", "> 0")
  spec.add_dependency("valise", "> 0")
  spec.add_dependency("tilt", "> 0")

  #spec.post_install_message = "Thanks for installing my gem!"
end
