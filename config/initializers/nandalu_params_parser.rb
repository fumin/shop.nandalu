class NandaluParamsParser
  def initialize app
    @app = app
  end
  def call env
    @app.call(change_path(env))
  end
  def change_path env
    ma = /^\/service\/(\w+)(\/[\w\/]*)/.match(env["PATH_INFO"])
    ma1 = /^\/service\/(\w+)$/.match(env["PATH_INFO"])
    if ma
      env.merge("PATH_INFO" => "/service", user_id: ma[1], service_path: ma[2])
    elsif ma1
      env.merge("PATH_INFO" => "/service", user_id: ma[1], service_path: "")
    else
      env
    end
  end
end # class NandaluParamsParser
