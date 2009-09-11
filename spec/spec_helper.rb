# $Id: email_controller.rb 856 2006-10-26 03:09:39Z pete $
# vim: ts=2 sw=2 ai expandtab

$KCODE='u'

module SMailMIMEHelperMethods
  def email_text_from_file(name)
    IO.read(File.dirname(__FILE__) + "/email/#{name}.txt")
  end
end
