# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 2025 Eric Crane.  All rights reserved.
#
# Information about a single asset.
# 
# Full Path is the full path to the file in the file system.
# Name is the name of the file with extension.
# PN is the path within assets and the name. 
#    ie: /asset/stylesheet/stylesheet.css
# Hash is the SHA256 hash of the file.
# Published Name is the name of the file that is published
#    to the web server, and includes the hash.
# 

module Gloo
  module WebSvr
    class AssetInfo

      # Class Variables
      @@index_by_published = {}
      @@index_by_pn = {}

      attr_reader :name, :pn, :published_name, :published_pn, :hash


      # ---------------------------------------------------------------------
      #    Initialization
      # ---------------------------------------------------------------------

      #
      # Set up an asset information object.
      #
      def initialize( engine, full_path, name, pn )
        @engine = engine
        @log = @engine.log

        @full_path = full_path
        @name = name
        @pn = pn
      end


      # ---------------------------------------------------------------------
      #    Functions
      # ---------------------------------------------------------------------

      # 
      # Register the asset with indexes, inflating all needed data elements.
      # 
      def register
        @log.info "*** REGISTERING ASSET: #{@name}"
        @log.info "*** #{@full_path} "
        @log.info "*** #PN: #{@pn} name: #{@name}"

        @hash = Gloo::Objs::FileHandle.hash_for_file( @full_path )
        # @log.info "*** Hash: #{@hash}"

        # Build published name
        ext = File.extname( @pn )           # Gets just the extension
        n = @name[ 0..-ext.length - 1 ]
        pn = @pn[ 0..-ext.length - 1 ]

        @published_name = "#{n}-#{@hash}#{ext}"
        @published_pn = "#{pn}-#{@hash}#{ext}"

        @log.info "*** Published Name: #{@published_name}"
        @log.info "*** Published Path: #{@published_pn}"

        # Add to indexes
        AssetInfo.index self
      end

      # 
      # Index the the given asset info record.
      # 
      def self.index info
        @@index_by_pn[ info.pn ] = info
        @@index_by_published[ info.published_pn ] = info
      end

      #
      # Find the asset info for the given published name.
      #
      def self.find_published_name_for pn
        return @@index_by_pn[ pn ].published_pn
      end

      def self.find_info_for pn
        return @@index_by_published[ pn ]
      end

      # 
      # List All assets.
      # 
      def self.list_all engine
        data = []
        @@index_by_pn.each do |pn, info|
          data << [ info.name, info.pn, info.published_pn ]
        end
        headers = [ "Name", "Asset Path", "Published" ]

        puts Gloo::App::Platform::RETURN
        title = "Assets in Running Web App"
        engine.platform.table.show headers, data, title
        puts Gloo::App::Platform::RETURN
      end

    end
  end
end