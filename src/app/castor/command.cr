#
# Abstract command
#
abstract class Application::Command
  abstract def run(args : Array(String))
end

