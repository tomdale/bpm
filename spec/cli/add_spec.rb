require 'spec_helper'
require 'json'

describe 'bpm add' do
  
  before do
    goto_home
    set_host
    env["GEM_HOME"] = bpm_dir.to_s
    env["GEM_PATH"] = bpm_dir.to_s
    start_fake(FakeGemServer.new)
    FileUtils.cp_r(fixtures('hello_world'), '.')
    cd home('hello_world')
  end

  def validate_dependency_in_project_file(package_name, package_version)
    json = JSON.parse File.read(home('hello_world', 'hello_world.json'))
    json['dependencies'][package_name].should == package_version
  end

  def validate_installed_dependency(package_name, package_version)
    pkg_path = home('hello_world', 'packages', package_name)
    if package_version
      File.exists?(pkg_path).should be_true
      pkg = BPM::Package.new(pkg_path)
      pkg.load_json
      pkg.version.should == package_version
    else
      File.exists?(pkg_path).should_not be_true
    end
  end
    
  def has_dependency(package_name, package_version)
    validate_dependency_in_project_file package_name, package_version
    validate_installed_dependency package_name, package_version
    # TODO: Verify packages built into bpm_packages.js and css
  end

  def has_soft_dependency(package_name, package_version)
    validate_dependency_in_project_file package_name, nil
    validate_installed_dependency package_name, package_version
    # TODO: Verify packages built into bpm_packages.js and css
  end
  
  def no_dependency(package_name)
    validate_dependency_in_project_file package_name, nil
    validate_installed_dependency package_name, nil
    # TODO: Verify packages not built into bpm_packages.js and css
  end
  
  it "must be called from within a project" do
    cd home # outside of project
    bpm "add", "jquery", :track_stderr => true
    stderr.read.should include("inside of a bpm project")
  end
  
  it "should add a new hard dependency" do
    bpm 'add', 'jquery'
    wait
    
    output = stdout.read
    output.should include('Added jquery (1.4.3)')
    has_dependency 'jquery', '1.4.3'
  end
  
  it "adds multiple package dependencies" do
    bpm "add", "jquery", "rake"
  
    output = stdout.read
  
    %w(jquery:1.4.3 rake:0.8.7).each do |pkg|
      pkg_name, pkg_version = pkg.split ':'
      output.should include("Added #{pkg_name} (#{pkg_version})")
      has_dependency pkg_name, pkg_version
    end
  end
  
  it "installs hard and soft dependencies" do
    bpm 'add', 'coffee', '--pre'
    wait
    
    output = stdout.read
    
    output.should include("Added coffee (1.0.1.pre)")
    output.should include("Added jquery (1.4.3)")
    
    has_dependency 'coffee', '1.0.1.pre'
    has_soft_dependency 'jquery', '1.4.3'
  end
  
  it "adds no packages when any are invalid" do
    bpm "add", "jquery", "fake", :track_stderr => true
  
    stderr.read.should include("Could not find package 'fake'")
  
    no_dependency 'jquery'
    no_dependency 'fake'
  end
  
  it "fails when adding invalid package" do
    bpm "add", "fake", :track_stderr => true
  
    stderr.read.should include("Could not find package 'fake'")
    no_dependency 'fake'
  end
  
  it "fails if bpm can't write to the json or packages directory" do
    FileUtils.mkdir_p home('hello_world', 'packages')
    FileUtils.chmod 0555, home('hello_world', 'packages')
    FileUtils.chmod 0555, home('hello_world', 'hello_world.json')
  
    bpm "add", "jquery", :track_stderr => true
    exit_status.should_not be_success
    no_dependency 'jquery'
  end
  
  it "adds packages with different versions" do
    bpm "add", "rake", "-v", "0.8.6"
  
    stdout.read.should include("Added rake (0.8.6)")
    has_dependency 'rake', '0.8.6'
  end
  
  it "updates a package to latest version" do
    bpm 'add', 'rake', '-v', '0.8.6'
    wait
    has_dependency 'rake', '0.8.6' # precond
  
    output = stdout.read
    bpm 'add', 'rake'
    wait
  
    output = stdout.read
    output.should_not include('Fetched spade') # not required 2nd time
    output.should_not include('Added spade (0.5.0)')
    output.should include('Added rake (0.8.7)')
    has_dependency 'rake', '0.8.7'
  end
  
  it "adds a valid prerelease package" do
    bpm "add", "bundler", "--pre", "--verbose"
    wait
    output = stdout.read
    output.should include("Added bundler (1.1.pre)")
    has_dependency 'bundler', '1.1.pre'
  end
  
  it "does not add the normal package when asking for a prerelease" do
    bpm "add", "rake", "--pre", :track_stderr => true
    wait
    stderr.read.should include("Could not find prerelease package 'rake'")
    no_dependency 'rake'
  end
  
  it "requires at least one package to add" do
    bpm "add", :track_stderr => true
    stderr.read.should include("at least one package")
  end

    
end