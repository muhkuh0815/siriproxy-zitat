# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'
require 'timeout'

#######
#
# This is simple plugin which read a random quotation from zitate-online.de
# and a random "useless lore" quote from unnuetzeswissen.info
#
#       Remember to put this plugins into the "./siriproxy/config.yml" file 
#######
#
# Ein einfaches Plugin, welches ein zufälliges Zitat von zitate-online.de vorliest
# und ein zufälliges "unnützes Wissen" von unnuetzeswissen.info
# 
#      ladet das Plugin in der "./siriproxy/config.yml" datei !
#######
## ##  WIE ES FUNKTIONIERT 
#
# sagt einen Satz mit "Zitat" oder "Spruch" -> zufälliges Zitat
# sagt einen Satz mit "Wissen"              -> zufälliges "unützes Wissen"
#
# bei Fragen Twitter: @muhkuh0815
# oder github.com/muhkuh0815/siriproxy-zitat
# noch kein Video
#
#### ToDo
#
#
#######

class SiriProxy::Plugin::Zitat< SiriProxy::Plugin
    
    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    def doc
    end
    def read(str)
      shaf = ""
      begin
	if str == "z" #zitat
	doc = Nokogiri::HTML(open("http://www.zitate-online.de/zufallszitat.txt.php"))
	elsif str == "w" #unnützes wissen
	doc = Nokogiri::HTML(open("http://unnuetzeswissen.info/zufaelliges-wissen.php"))
	end
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
      if str == "z" #zitat
	doc.gsub!(/(von zitate-online.de)/, "")
	zit = doc.strip
      elsif str = "w" #wissen
	  wisa = doc.match("Hinzugefügt am ")            #searches the beginning of the quote
	  wisb = wisa.post_match.match("\t")             #searches for first 'tab' after this
	  wisc = wisb.post_match.match("Eingereicht von ") # search for the end of the quote
	  wis = wisc.pre_match
	  zit = wis.strip
      end
      zit.gsub!(/\t/, "")   # clear tabulators
      zit.gsub!(/\n/, "")   # clear linebreaks
    return zit
    end
    end

# random Zitat
listen_for /(Zitat|Spruch)/i do
  zitat = read('z') 
  if zitat == nil
    say "Fehler!" , spoken: ""
  else
    zit = zitat.to_s
    if zit.match(": ")
      zita = zit.match(": ")             #searches for the separator
      zitaa = zita.pre_match             #gives author
      zitab = zita.post_match            #gives quotation
      zitat = zitab + " \n\n" + zitaa    #reverse order  author: "xx"  to  "xx" - author
      say zitat.to_s, spoken: zitab.to_s #reads just the quotation not the author
    else
      say zit.to_s
    end
  end
  request_completed
end

# random unnützes Wissen
listen_for /(Wissen)/i do
  wissen = read('w') 
  if wissen == nil
    say "Fehler!" , spoken: ""
  else
    say wissen.to_s
  end
  request_completed
end

end

