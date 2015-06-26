module Pmlatex
  class OverPic
    include TexHelper
    def initialize
    end
    
    def parallel_mv(p, d)
      m = []
      m[0] = p[0] + d[0]
      m[1] = p[1] + d[1]
      return m
    end

    def descartes2polar(x,y)
      r = Math.sqrt(x*x + y*y)
      th = Math.atan2(y, x)
      return [r,th]
    end

    def polar2descartes(r,th)
      x = r * Math.cos(th)
      y = r * Math.sin(th)
      return [x,y]
    end

    def radian2degree(rad)
        return (rad/Math::PI * 180)
    end

    def degree2radian(deg)
        return (deg * Math::PI / 180)
    end
    

    def isocircle(diameter, angle)
      radius = diameter.to_f / 2
      circle(diameter) + rotatebox(angle,vector(0,1,radius))
    end


    def rotatebox(angle, content)
      "\\rotatebox{#{angle}}{#{content}}"
    end

    def vector(x,y,length)
      "\\vector(#{x},#{y}){#{length}}"
    end

    def onspot(content)
      "\\onspot #{content}"
    end

    def circle(diameter, options = {})
      tex = "\\circle{#{diameter}}"
      tex
    end

    def line(x,y,size)
      tex = "\\line(#{x},#{y}){#{size}}"
      tex
    end

    def linethickness(thick)
      tex = "\\linethickness{#{thick}}"
    end

    def makebox(x,y,content,position = "c")
      "\\makebox(#{x},#{y})[#{position}]{#{content}}"
    end

    def colorbox(color, content)
      "\\colorbox{#{color}}{#{content}}"
    end

    def color(color)
      "\\color{#{color}}"      
    end

    def data(content)
      "\\data{#{content}}"
    end

    def put(x,y,content)
      "\\put(#{x},#{y}){#{content}}"
    end

    def fmt(num)
      format("%.3f",num)
    end

    def qbezier(sp,mp,ep)
      "\\qbezier(#{fmt(sp[0])},#{fmt(sp[1])})(#{fmt(mp[0])},#{fmt(mp[1])})(#{fmt(ep[0])},#{fmt(ep[1])})"
    end

    def segment(sp,ep)
      mp = []
      mp[0] = (sp[0] + ep[0])/2
      mp[1] = (sp[1] + ep[1])/2
      qbezier(sp,mp,ep)
    end

    def put_isoclock(x,y,iso,options={})
      x = x.to_f
      y = y.to_f
      radius = options[:radius] || 10
      range = options[:range] || [-20,20]
      caption = options[:caption]
      iso = iso.to_f
      iso_range_min = range[0]
      iso_range_max = range[1]
      thread_hour       = (((iso - iso_range_min)/(iso_range_max - iso_range_min) * (-360) + 180)) % 360;
      thread_minute_org = ((iso.to_i % 10) / 10.0 * (-360)) % 360;
      thread_minute     = (((iso*10).to_i % 100) / 100.0 * (-360)) % 360;
      thread_sec        = (((iso * 10) % 10) / 10 * (-360)) % 360;

      base_content = circle(radius * 2)
      base_content += rotatebox(thread_hour,line(0,1,radius*1.0) + line(0,-1,radius*1.0))

      content = circle(radius * 2)
      content += rotatebox(thread_hour,linethickness("1.6pt") + vector(0,1,radius*1.0) + line(0,-1,radius*1.0))
      #content += rotatebox(thread_minute,line(0,1,radius*0.85))
      #content += " " + onspot(options[:caption]) if options[:caption]
      tex = "% isoclock x=#{x} y=#{y} isotope=#{iso}\n"
      tex += color("white") + linethickness("3.2pt") + "\n"
      tex += put(x,y, base_content) + "\n"
      tex += color("black") + linethickness("1.6pt") + "\n"
      tex += put(x, y, content) + "\n"
      cp = parallel_mv(polar2descartes(radius * 1.2,Math::PI/2),[x,y])
      tex += put(cp[0], cp[1], onspot(options[:caption])) if options[:caption]    
      tex += tick_for_circle(x, y, radius, degree2radian(thread_sec + 90), :length => 20.0)

      num_ticks = 10
      if options[:ticks]
        diso = (iso_range_max - iso_range_min) / num_ticks.to_f
        ddeg = - 360.0 / num_ticks.to_f
        deg = 270
        tiso = iso_range_min

        radian = degree2radian(deg)
        tex += tick_for_circle(x, y, radius, radian)
        # tex += caption_for_circle(x, y, radius, radian, format("%.1f,%.1f",iso_range_min,iso_range_max)) if options[:tick_captions]      
        tex += caption_for_circle(x, y, radius, radian, format("%g,%g",iso_range_min,iso_range_max)) if options[:tick_captions]      
        (num_ticks - 1).times do |i|
          deg += ddeg
          tiso += diso
          radian = degree2radian(deg)
          tex += tick_for_circle(x, y, radius, radian)
          # tex += caption_for_circle(x, y, radius, radian, format("%.1f",tiso)) if options[:tick_captions]
          tex += caption_for_circle(x, y, radius, radian, format("%g",tiso)) if options[:tick_captions]
        end
      end
      tex
    end


    def tick_for_circle(x,y,radius,radian,options = {})
      x,y = x.to_f, y.to_f
      percent = options[:length] || 10.0
      tick_length = radius * percent/100.0
      sp = parallel_mv(polar2descartes(radius-tick_length,radian),[x,y])
      # 
      # p parallel_mv(sp,[x,y])
      # sp[0] += x
      # sp[1] += y
      # p sp
      ep = parallel_mv(polar2descartes(radius,radian),[x,y])
      # 
      # ep[0] += x
      # ep[1] += y
      segment(sp,ep)
    end

    def caption_for_circle(x,y,radius,radian,text)
      x,y = x.to_f, y.to_f
      sp = polar2descartes(radius*1.15,radian)
      sp[0] += x
      sp[1] += y
      ep = polar2descartes(radius,radian)
      ep[0] += x
      ep[1] += y
      mydegree = (radian2degree(radian)-90)%90
      put(sp[0],sp[1],makebox(0,0,"\\rotatebox{#{mydegree}}{\\color{red}\\tiny{#{text}}}"))
    end


    def put_isocircle(x,y,iso,options={})
      radius        = options[:radius] || 10
      range         = options[:range] || [-20,20]
      caption       = options[:caption]
      iso           = iso.to_f
      iso_range_min = range[0]
      iso_range_max = range[1]

      fdeg = Proc.new{|isotope| ((isotope - iso_range_min)/(iso_range_max - iso_range_min) * (-300) + 150) % 360 }
      deg_range_start = fdeg.call(iso_range_min)
      deg = fdeg.call(iso)
      deg_range_end = fdeg.call(iso_range_max)
      deg_range = 360 - (deg_range_end - deg_range_start)
      content = circle(radius * 2)
      content += rotatebox(deg,vector(0,1,radius))

      content += " " + onspot(options[:caption]) if options[:caption]
      tex = "%isocircle\n"
      tex += put(x, y, content)
      num_ticks = 10
      if options[:ticks]
        diso = (iso_range_max - iso_range_min) / num_ticks.to_f
        ddeg = - deg_range / num_ticks.to_f
        deg  = deg_range_start
        tiso = iso_range_min

        radian = degree2radian(deg)
        (num_ticks + 1).times do |i|
          radian = degree2radian(deg)
          tex += tick_for_circle(x, y, radius, radian)
          tex += caption_for_circle(x, y, radius, radian, format("%.1f",tiso)) if options[:tick_captions]
          deg += ddeg
          tiso += diso
        end
      end
      tex

    end  

    def put_isocircle_old(x, y, r1, deg, options ={})
      content = isocircle(r1, deg)
      content += " " + onspot(options[:caption]) if options[:caption]
      tex = put(x, y, content)
      if options[:ticks]
        range = options[:ticks]

        drad = Math::PI * 2 / 10
        radius = r1/2
        rad = Math::PI/2
        10.times.each do |i|
           rad += drad
           sp = polar2descartes(radius-radius/10.0,rad)
           sp[0] += x
           sp[1] += y
           ep = polar2descartes(radius,rad)
           ep[0] += x
           ep[1] += y
           tex += segment(sp,ep)
        end
      end
      tex
    end

    def put_isocircle_graphic(x, y, r1, deg, options = {})
      content = includegraphics('iso-circle', sprintf("width=%g\\textwidth,angle=%g",r1,deg))
      content += " " + onspot(options[:text]) if options[:text]
      put(x, y, content)
    end

    def put_circle(x, y, size, options = {})
      content = circle(size)
      content += " " + onspot(options[:caption]) if options[:caption]
      put(x, y, content)
    end

  end
end
