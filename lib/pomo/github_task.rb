require 'octokit'

module Pomo
  class GithubTask < Task

    ##
    # Username.

    attr_accessor :username

    ##
    # Project name.

    attr_accessor :project

    ##
    # Labels array.

    attr_accessor :labels

    ##
    # Issue number.

    attr_accessor :number

    ##
    # Absolute URI.

    attr_accessor :url

    ##
    # Initialize with _name_ and _options_.

    def initialize(name = nil, options = {})
      super
      options.each { |k,v| send :"#{k}=", v }
    end

    ##
    # Quoted github issue name and number.

    def to_s
      "#%-3s %s" % [ number, name]
    end

    ##
    # Output verbose task information.

    def verbose_output(format)
      super(format)
      say format % ['labels', labels.join(', ')] if labels and not labels.empty?
      say format % ['project', [username, project].join('/')]
      say format % ['url', url ]
    end

    ##
    # Import Github issue(s) with _user_, _project_, _number_ as GithubTask(s).

    def self.import(user, project, number)
      tasks = []
      if number
        issues = [Octokit.issue({:username => user, :repo => project}, number)]
      else
        issues = Octokit.list_issues({:username => user, :repo => project}, :state => 'open', :sort => 'created')
      end

      issues.each do |issue|
        tasks << new(issue.title,
          :username => user,
          :project => project,
          :description => issue.body,
          :labels => issue.labels.map(&:name),
          :number => issue.number,
          :url => issue.html_url
        )
      end
      return tasks
    rescue Octokit::NotFound => e
      say "\n"
      say_error '404: This is not the repo you are looking for.'
      say_error e.message
      abort
    end
  end
end
