# AdminModule

AdminModule is a tool to allow maintenance and configuration of AMS
environments through the command line or Rake tasks.

Because it is scriptable, it can be used to create efficient and repeatable
migrations resulting in low risk deployments.

## Installation

Add this line to your application's Gemfile:

    gem 'admin_module'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install admin_module

## Usage

### Command Line Help

Thor's usage help is messed up related to subcommands (ie. subcommand help is
sometimes listed without the subcommand's parent). For this reason, the 'help'
is listed here.

    $ admin_module help

    Commands:
      admin_module help [COMMAND]     # Describe available commands or one specific command
      admin_module config [COMMAND]   # modify configuration values
      admin_module gdl [COMMAND]      # run a guideline command
      admin_module lock [COMMAND]     # run a lock command
      admin_module rule [COMMAND]     # run a rule command
      admin_module ruleset [COMMAND]  # run a ruleset command
      admin_module stage [COMMAND]    # run a stage command


#### Config Commands

    $ admin_module config help

    Commands:
      admin_module config help [COMMAND]          # Describe subcommands or one specific subcommand
      admin_module config defcomment '<comment>'  # show or set the default comment
      admin_module config defenv <envname>        # show or set the default environment
      admin_module config init <filedir>          # create a configuration file
      admin_module config timeout <seconds>       # show or set the browser timeout period
      admin_module config show [CATEGORY]         # display configuration values for [CATEGORY]
      admin_module config add [CATEGORY]          # add a configuration value
      admin_module config del [CATEGORY]          # delete a configuration value for [CATEGORY]


##### Config Show Commands

    $ admin_module config show help

    Commands:
      admin_module config show help [COMMAND]         # Describe subcommands or one specific subcommand
      admin_module config show credentials <envname>  # display configured credentials for an environment
      admin_module config show envs                   # display configured environments
      admin_module config show xmlmaps                # display configured xmlmaps


##### Config Add Commands

    $ admin_module config add help

    Commands:
      admin_module config add help [COMMAND]                           # Describe subcommands or one specific subcommand
      admin_module config add credentials <envname> <username> <pass>  # add login credentials for an environment
      admin_module config add env <envname> <url>                      # add a environment url
      admin_module config add xmlmap <xmlfile> <gdlname>               # map an xml file name to a guideline


##### Config Del Commands

    $ admin_module config del help

    Commands:
      admin_module config del help [COMMAND]         # Describe subcommands or one specific subcommand
      admin_module config del credentials <envname>  # delete credentials for an environment
      admin_module config del env <envname>          # delete an environment configuration
      admin_module config del xmlmap <xmlfile>       # delete an xml file to guideline mapping


#### Gdl Commands

    $ admin_module gdl help

    Commands:
      admin_module gdl help [COMMAND]              # Describe subcommands or one specific subcommand
      admin_module gdl deploy <srcdir> <comments>  # Deploy all XML files in <srcdir> with version <comments>
      admin_module gdl version <comments>          # Version guidelines with <comments>

    Options:
      e, [--environment=dev]


#### Lock Commands

    $ admin_module lock help

    Commands:
      admin_module lock help [COMMAND]               # Describe subcommands or one specific subcommand
      admin_module lock export <filepath>            # Export a lock configuration file from the environment
      admin_module lock import <filepath>            # Import a lock configuration file into the environment
      admin_module lock list                         # List all locks in the environment
      admin_module lock read <name>                  # Emit a lock's configuration from the environment in YAML format
      admin_module lock rename <srcname> <destname>  # Rename a lock named <srcname> to <destname>

    Options:
      e, [--environment=dev]


#### Rule Commands

    $ admin_module rule help

    Commands:
      admin_module rule help [COMMAND]               # Describe subcommands or one specific subcommand
      admin_module rule delete <rulename>            # Delete a rule named <rulename>
      admin_module rule list                         # List all rules in the environment
      admin_module rule rename <srcname> <destname>  # Rename a rule named <srcname> to <destname>

    Options:
      e, [--environment=dev]


#### Ruleset Commands

    $ admin_module ruleset help

    Commands:
      admin_module ruleset help [COMMAND]               # Describe subcommands or one specific subcommand
      admin_module ruleset list                         # List all rulesets in the environment
      admin_module ruleset rename <srcname> <destname>  # Rename a ruleset named <srcname> to <destname>

    Options:
      e, [--environment=dev]


#### Stage Commands

    $ admin_module stage help

    Commands:
      admin_module stage help [COMMAND]               # Describe subcommands or one specific subcommand
      admin_module stage delete <name>                # Delete a stage from the environment
      admin_module stage export <filepath>            # Export a stage configuration file from the environment
      admin_module stage import <filepath>            # Import a stage configuration file into the environment
      admin_module stage list                         # List all stages in the environment
      admin_module stage read <name>                  # Emit a stage's configuration from the environment in YAML format
      admin_module stage rename <srcname> <destname>  # Rename a stage from <srcname> to <destname>

    Options:
      e, [--environment=dev]




### Tasks

AdminModule provides tasks you can use in your rake file.

#### Stage Tasks

Add `require 'admin_module/rake/stage_tasks'` to your rake file and
`admin_module` will add a set of `stage` tasks for each configured
environment. All tasks are prefixed with `am:ENV_NAME:`.

Task options are displayed within brackets like so: `am:dev:stage:read[name]`.
If the option contains spaces, surround the option, or the entire task name
with single or double quotes:

    rake am:dev:stage:read['Some Stage Name']

    # or

    rake 'am:dev:stage:read[Some Stage Name]'


Tasks include:

- `stage:delete` deletes a stage
- `stage:export` exports all stages to a yaml file
- `stage:import` imports stage configs from a yaml file
  - the `allow_create` flag is optional. Default: `false`. If `true`, stages can be created during import.
- `stage:list` list all stage names
- `stage:read` output a stage configuration in yaml format
- `stage:rename` rename an existing stage


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## ToDo

* document CLI
* complete conversion to `thor`
* snapshot configuration
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


