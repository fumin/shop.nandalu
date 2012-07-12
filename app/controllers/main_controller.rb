require 'mdcliapi2'

class MainController < ApplicationController
  skip_before_filter :authorize
  def aboutus
  end

  def contactus
  end

  def route_login
    r = Route.find_by_user_name(params[:user_name])
    if r.password == params[:password]
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

    #client = MajorDomoClient.new('tcp://geneva3.godfat.org:5555')
    puts "client connected!"
    requests = 100
    requests.times do |i|
      request = env[:service_path] # 'Hello world'
      begin
        client.send(service, request)
	#client.send('echo', request)
        puts "i = #{i}"
      end
    end

    count = 0
    while count < requests do
      begin
	reply = client.recv
        puts "count = #{count}, reply = #{reply}"
      end
      count += 1
    end

    client.close

    @msg = "#{count} requests/replies processed env[:user_id] = #{env[:user_id]}, env[:service_path] = #{env[:service_path]}"
    puts "#{count} requests/replies processed"
  end
end
