# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'
require 'timeout'

#######
#
# This is simple plugin which read a random quotation from zitate-online.de
#
#       Remember to put this plugins into the "./siriproxy/config.yml" file 
#######
#
# Ein einfaches Plugin, welches ein zufälliges Zitat von zitate-online.de vorliest
# 
#      ladet das Plugin in der "./siriproxy/config.yml" datei !
#######
## ##  WIE ES FUNKTIONIERT 
#
# sagt einfach einen Satz mit "Zitat" oder "Spruch" 
#
# bei Fragen Twitter: @muhkuh0815
# oder github.com/muhkuh0815/siriproxy-zitat
# noch kein Video
#
#### ToDo
#
# all done
#
#######

class SiriProxy::Plugin::Zitat< SiriProxy::Plugin
    
    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    def doc
    end
    def read()
      shaf = ""
      begin
	doc = Nokogiri::HTML(open("http://www.zitate-online.de/zufallszitat.txt.php"))
	doc.encoding = 'utf-8'
      rescue Timeout::Error
	print "Timeout-Error beim Lesen der Seite"
	shaf ="timeout"
      rescue
	print "Lesefehler !"
	shaf ="timeout"
      end
    if shaf =="timeout" 
    say "Es gab ein Problem beim einlesen der Daten!"
    else
      doc = doc.to_s
      doc.gsub!(/<\/?[^>]*>/, "") #deletes html code
      doc.gsub!(/(von zitate-online.de)/, "")
      zit = doc.strip
    return zit
    end
    end

# random Zitat
listen_for /(Zitat|Spruch)/i do
  zitat = read() 
  if zitat == nil
  else
    zit = zitat.to_s
    zita = zit.match(": ")             #searches for the separator
    zitaa = zita.pre_match             #gives author
    zitab = zita.post_match            #gives quotation
    zitat = zitab + " - " + zitaa      #reverse order  author: "xx"  to  "xx" - author
    say zitat.to_s, spoken: zitab.to_s #reads just the quotation not the author
  end
  request_completed
end


end

