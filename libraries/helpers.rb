# Module for alteryx-server Cookbook so that LWRPs stay clean
module AlteryxServer
  # Module for helper functions and classes withing alteryx-server Cookbook
  module Helpers
    def self.exe_glob(dir)
      exe = Dir.glob("#{dir}*.exe")[0]
      exe.gsub('/', '\\')
    end
  end
end
