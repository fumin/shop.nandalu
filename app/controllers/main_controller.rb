require 'mdcliapi2'

class MainController < ApplicationController
  skip_before_filter :authorize
  def aboutus
  end

  def contactus
  end

  def route_login
    r = Route.find_by_user_name(params[:user_name])
    if r && r.password == params[:password]
      current_service_hash = SecureRandom.uuid
      r.current_service_hash = current_service_hash
      r.save
      render text: current_service_hash
    else
      render nothing: true
    end
  end

  def zmq
    r = Route.find_by_user_name(env[:user_id])
    unless r
      @msg = "The apple device #{env[:user_id]} you requested is not registered"
      return
    end
    service = r.current_service_hash
    client = MajorDomoClient.new('tcp://geneva3.godfat.org:5555')
    client.send('mmi.service', service)
    reply = client.recv
    puts "Lookup #{service} service: #{reply}"
    unless reply == ["200"]
      client.close
      @msg = "The apple device #{env[:user_id]} you requested is not online"
      return
    end
    request = env[:service_path]

    # querying for an image
    m = %r{^/images/(?<img_index>\d+)(?:\.[[:alpha:]]+)?$}.match(request)
    if m
      client.send(service, request)
      #image = client.recv().join("")
      #client.close
      self.response.headers["Content-Type"] = "image/jpeg"
      self.response.headers["Content-Disposition"] = "inline; filename=#{m['img_index']}.jpg"
      self.response.headers["Last-Modified"] = Time.now.ctime.to_s
      self.response_body = Enumerator.new do |y|
                             more_parts = true
                             while more_parts
                               buf = client.recv()
                               more_parts = false if buf.size == 1
puts "[DEBUG] we've recved, more_parts = #{more_parts}, buf[0].size = #{buf[0].size} #{Time.now}"
                               y << Zlib.inflate(buf[0])
                             end
                           end
      #send_data image, file_name: "#{m[1]}.jpg",
      #          type: "image/jpeg", disposition: "inline"
    end

  end
end
