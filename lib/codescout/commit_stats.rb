require "git"
require "logger"

module Codescout
  class CommitStats
    def initialize(analyzer)
    end

    def to_hash
      {
        commit:          commit.sha,
        author:          commit.author.name,
        author_email:    commit.author.email,
        committer:       commit.committer.name,
        committer_email: commit.committer.email,
        branch:          commit.name,
        message:         commit.message
      }
    end

    private

    def git
      @git ||= Git.open(".", log: Logger.new(STDERR))
    end

    def commit
      @commit ||= git.gcommit("HEAD")
    end
  end
end