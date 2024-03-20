# Author::    Eric Crane  (mailto:eric.crane@mac.com)
# Copyright:: Copyright (c) 20124 Eric Crane.  All rights reserved.
#
# Standard Response Codes.
# 
# See:
#    https://en.wikipedia.org/wiki/List_of_HTTP_status_codes 
#    https://www.geeksforgeeks.org/10-most-common-http-status-codes/
# 

module Gloo
  module WebSvr
    class ResponseCode

      # Gloo::WebSvr::ResponseCode::SUCCESS
      SUCCESS = 200.freeze
      CODE_200 = 'Success/OK'.freeze

      CREATED = 201.freeze
      CODE_201 = 'Created'.freeze

      ACCEPTED = 202.freeze
      CODE_202 = 'Accepted'.freeze

      NO_CONTENT = 204.freeze
      CODE_204 = 'No Content'.freeze

      PARTIAL_CONTENT = 206.freeze
      CODE_206 = 'Partial Content'.freeze

      MOVED_PERM = 301.freeze
      CODE_301 = 'Moved Permanently'.freeze
      
      FOUND = 302.freeze
      CODE_302 = 'Found'.freeze

      SEE_OTHER = 303.freeze
      CODE_303 = 'See Other'.freeze

      NOT_MODIFIED = 304.freeze
      CODE_304 = 'Not Modified'.freeze

      TEMP_REDIRECT = 307.freeze
      CODE_307 = 'Temporary Redirect'.freeze

      PERM_REDIRECT = 307.freeze
      CODE_308 = 'Permanent Redirect'.freeze

      BAD_REQUEST = 400.freeze
      CODE_400 = 'Bad Request'.freeze

      UNAUTHORIZED = 401.freeze
      CODE_401 = 'Unauthorized'.freeze

      FORBIDDEN = 403.freeze
      CODE_403 = 'Forbidden'.freeze

      NOT_FOUND = 404.freeze
      CODE_404 = 'Not Found'.freeze

      SERVER_ERR = 500.freeze
      CODE_500 = 'Internal Server Error'.freeze

      NOT_IMPLEMENTED = 501.freeze
      CODE_501 = 'Not Implemented'.freeze

    end
  end
end
