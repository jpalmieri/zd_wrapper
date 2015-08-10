# Colorize, thanks to Ivan Black on Stack Overflow
class String
def black;          "\033[30m#{self}\033[0m" end
def red;            "\033[31m#{self}\033[0m" end
def green;          "\033[32m#{self}\033[0m" end
def brown;          "\033[33m#{self}\033[0m" end
def blue;           "\033[34m#{self}\033[0m" end
def magenta;        "\033[35m#{self}\033[0m" end
def cyan;           "\033[36m#{self}\033[0m" end
def gray;           "\033[37m#{self}\033[0m" end
def bg_black;       "\033[40m#{self}\033[0m" end
def bg_red;         "\033[41m#{self}\033[0m" end
def bg_green;       "\033[42m#{self}\033[0m" end
def bg_brown;       "\033[43m#{self}\033[0m" end
def bg_blue;        "\033[44m#{self}\033[0m" end
def bg_magenta;     "\033[45m#{self}\033[0m" end
def bg_cyan;        "\033[46m#{self}\033[0m" end
def bg_gray;        "\033[47m#{self}\033[0m" end
def bold;           "\033[1m#{self}\033[22m" end
def reverse_color;  "\033[7m#{self}\033[27m" end
end

class CLIStrings
  def performing(request, endpoint)
    "Performing a #{request.upcase} request at #{endpoint.blue.bold}, this might take a while..."
  end
  def warning(endpoint)
    "WARNING: YOU ARE ABOUT TO IRREVERSIBLY DELETE DATA FROM THE ".bg_red + 
      @env.to_s.upcase.bold.bg_red + " HELP CENTER ".bg_red +
      "AT THE FOLLOWING ENDPOINT: #{endpoint.bold}\n".bg_red +
      "THIS ACTION CANNOT BE UNDONE. MAKE SURE YOU UNDERSTAND ".bg_red + 
      "WHAT YOUR SCRIPT IS DELETING. ENTER ".bg_red + 
      '"I UNDERSTAND I AM IRREVERSIBLY DELETING DATA" '.bg_red.bold +
      "BELOW TO CONTINUE:".bg_red
  end
  def warning_confirmation
    "I UNDERSTAND I AM IRREVERSIBLY DELETING DATA"
  end
  def warning_failed
    "Confirmation failed, operation aborted.".red.bold
  end
  def http_response(code, message, body)
    "Response: #{code} #{message}\n#{body}"
  end
  def page_msg(current_page)
    "Page #{current_page}"
  end
end
