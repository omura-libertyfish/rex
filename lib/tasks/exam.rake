require Rails.root.join('lib/tasks/deploy')

namespace :exam do
  desc "Deploy ExamMaster to database"

  task deploy: [:load_yaml, :environment] do
    # clean repos
    Rake::Task["exam:clean"].invoke

    # clone repos
    system("git clone -b #{@git['branch']} #{@git['repos']} #{@repos_path}")

    # check markdown files
    uuid_regexp = /\A#{@repos_path.join('[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}')}\z/
    uuids = Dir.glob(@repos_path.join('*')).select{|path| path.match uuid_regexp}.map{|path| Pathname.new(path)}

    # load markdown
    Deploy::execute(uuids, @relation)
  end

  desc "Clean up exam-master working directory"
  task clean: [:load_yaml] do
    if File.exists?(@repos_path)
      puts "Clean up tmp/cache/repos"
      FileUtils.rm_rf(@repos_path)
    else
      puts "'tmp/cache/repos' is not cloned yet"
    end
  end

  desc "Create 'env.yml.sample'"
  task init: [:load_yaml, :environment] do
    markdown_files = Deploy::markdown_files(@relation)

    File.open(Rails.root.join("env.yml.sample"), 'w') {|io|
      io.write({'markdown' => markdown_files, 'default' => @default}.to_yaml)
    }
  end

  task :load_yaml do
    # load yaml file
    yaml = YAML.load_file Rails.root.join("lib/tasks/config/env.yml")
    @git = yaml['git']
    @relation = yaml['relation']
    @default = yaml['default']

    # git clone path
    @repos_path = Rails.root.join('tmp/cache/repos')
  end
end
