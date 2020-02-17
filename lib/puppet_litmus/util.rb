# frozen_string_literal: true

# Helper methods for testing puppet content
module PuppetLitmus::Util
  # Ensure that a passed command is base 64 encoded and passed to PowerShell; this obviates the need to
  # carefully interpolate strings for passing to ruby which will then be passed to PowerShell/CMD which will
  # then be executed. This also ensures that a single PowerShell command may be specified for Windows targets
  # leveraging PowerShell as bolt run_shell will use PowerShell against a remote target but CMD against a
  # localhost target.
  #
  # @param :command [String] A PowerShell script block to be converted to base64
  # @return [String] An invocation for PowerShell with the encoded command which may be passed to run_shell
  def self.interpolate_powershell(command)
    encoded_command = Base64.strict_encode64(command.encode('UTF-16LE'))
    "powershell.exe -NoProfile -EncodedCommand #{encoded_command}"
  end
end
