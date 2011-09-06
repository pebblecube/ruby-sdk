#!/usr/bin/env ruby
#
# Copyright 2011 Pebblecube
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
require 'rubygems'
require 'digest/md5'
require 'net/https'
require 'uri'
require 'cgi'
require 'json'
require 'openssl'
require 'base64'
require 'pebblecube_session'

module Pebblecube
  
  #
  #Provides access to the Pebblecube apis
  #
  class PebblecubeApi
    attr_accessor :key, :secret, :sig, :server_url, :session, :cipher
    
    # Returns the size for the encryption key
    def cipher_block_size()
      case @cipher
        when "256"
          return 32
        when "192"
          return 24
        else
          return 16
      end
    end
    
    def initialize(key, secret, cipher = nil)
      @key = key
      @secret = secret
      @sig = Digest::MD5.hexdigest(key+secret)
      @server_url = "https://api.pebblecube.com"
      @cipher = cipher
      @session = PebblecubeSession.new(self)
    end
    
    def request(url, method = 'GET', params = nil)
      
      if not params
        params = Hash.new
      end
      
      #adding iv param only if encryption required
      req_headers = Hash.new
      if @cipher
        req_headers['PC_IV'] = Base64.encode64(OpenSSL::Random.random_bytes(16))
        #todo: add encrypted params 
      end
      
      #standard params
      params["api_sig"] = @sig
      params["api_key"] = @key
      
      method_url = URI.parse("#{@server_url}#{url}")
      http = Net::HTTP.new(method_url.host, method_url.port)
      
      #https
      if method_url.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
      end
      
      begin
        
        #temporary only GET is implemented
        querystring = params.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")
        body = ""
        headers = nil
        result = http.start {
          http.request_get("#{method_url.path}?#{querystring}", req_headers) {|res|
        	  body = res.body
        	  headers = res.header
          }
        }
        
        if Net::HTTPSuccess || Net::HTTPRedirection
          result = JSON.parse(decrypt(body, headers["PC_IV"]))
        else
          raise pebblecube.PebblecubeException result["e"]
        end
        
      rescue Exception => ex
        raise ex
      end
      
      return result
      
    end
    
    # Encrypts a string using aes, mode of operation cbc.
    #
    # == Parameters:
    # text::
    #   text to encrypt
    # iv::
    #   Initialition vector
    #
    # == Returns:
    # Encrypted string
    #
    def encrypt(text, iv)
      if @cipher
        cipher = OpenSSL::Cipher::Cipher.new("aes-#{@cipher}-cbc")
        cipher.encrypt
        cipher.key = @secret[0..@cipher_block_size]
        if iv != ""
          cipher.iv = iv
        end
        cipher_text = cipher.update(text)
        cipher_text << cipher.final
        return Base64.encode64(cipher_text) #output in base64
      else
        return text
      end
    end
    
    # Decrypts a base64 string using aes, mode of operation cbc.
    #
    # == Parameters:
    # text64::
    #   base64 text
    # iv::
    #   Initialition vector
    #
    # == Returns:
    # Decrypted string
    #
    def decrypt(text64, iv)
      if @cipher
        cipher = OpenSSL::Cipher::Cipher.new("aes-#{@cipher}-cbc")
        cipher.decrypt
        cipher.key = @secret[0..cipher_block_size]
        if iv != ""
          cipher.iv = Base64.decode64(iv)
        end
        decrypted_text = cipher.update(Base64.decode64(text64))
        decrypted_text << cipher.final
        return decrypted_text
      else
        return text64
      end
    end
    
  end
  
  class PebblecubeException < RuntimeError
  end
  
end