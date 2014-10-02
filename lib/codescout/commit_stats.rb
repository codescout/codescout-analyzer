require "git"
require "logger"
require "pp"

module Codescout
  class CommitStats
    def initialize(analyzer)
      git = Git.open(".", log: Logger.new(STDERR))
      commit = git.gcommit("HEAD")

      @hash = {
        commit:          commit.sha,
        author:          commit.author.name,
        author_email:    commit.author.email,
        committer:       commit.committer.name,
        committer_email: commit.committer.email,
        branch:          commit.name,
        message:         commit.message
      }
    end

    def to_hash
      @hash
    end
  end
end