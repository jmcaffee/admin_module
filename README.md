# AdminModule

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'admin_module'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install admin_module

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## ToDo

* snapshot configuration
* add groups to stage config
* add tasks to stage config
* tasks configuration
* PPM configuration

## Process Flow (CLI)

- Command entered in console
- `lib/admin_module/cli.rb` processes args
- `cli.rb` hands command off to `lib/admin_module/cli/gdl.rb`
- `gdl.rb` validates command and hands off to `lib/admin_module/guideline.rb`
- `guideline.rb` processes command and uses `lib/admin_module/page_factory.rb`
  to get instance of web page objects needed to fulfill command request
- `guideline.rb` completes command

## Process Flow (Rake Task)

- Rake imports/requires `lib/admin_module/rake/deploy_task.rb`
- Rake task requires API object `lib/admin_module/guideline.rb`
- API object processes task request, gets needed page objects from `page_factory.rb`
- API object completes task request, returns control to task

## Thor Conversion Process

Detailing the conversion steps taken while converting to Thor CLI interface.

1. Create CLI spec for new interface (`spec/lib/admin_module/cli/gdl_spec.rb`)
2. Create new CLI object (`lib/admin_module/cli/gdl.rb`)
3. Create API spec for API object (`spec/lib/admin_module/guideline_spec.rb`)
4. Create new/modify existing API object (`lib/admin_module/guideline.rb`)
5. Make tests/specs pass
6. Delete old CLI object (`lib/admin_module/cli/cli_guideline.rb`)

### Create CLI Spec

Create a new spec file `spec/lib/admin_module/cli/gdl_spec.rb`.

Create a new CLI object `lib/admin_module/cli/gdl.rb`.

Edit `lib/admin_module/cli.rb` creating new base command pointing to new object
(`AdminModule::Gdl` in this case).

Create `lib/admin_module/guideline.rb` which is an object that provides an API
interface to the actual Guideline page object.

- The Guideline page object only contains functionality that the actual webpage
  contains, ie. Add, Modify, Delete
- The Guideline API object contains functionality that manipulates the webpage
  object to provide results. Maybe this means it uses the page object to lookup
  the available guidelines, throw an error if a guidline doesn't exist, or
  deletes a guideline if exists.
- The API object also hides the fact that the app needs to go to a _Guidelines_
  page, select a guideline, then go to the _GuidelineDetails_ page before it can
  manipulate a guideline, say, to change its name.


