# encoding: utf-8
  class WeixinController <AppController

  #微信检测
  def weixin_message_center_get
    return render :text => "error" if (check_signature == false || params[:echostr].nil?)
    render :text => params[:echostr]
  end

  #微信消息响应
  def weixin_message_center_post
    if check_signature == false
      render :text => "error"
      return
    end
    response_msg
  end

  def login
   #自定义代码，公众号点击进入的入口。
  end
 
  private

  def http_get_openid(code)
    url="https://api.weixin.qq.com/sns/oauth2/access_token?appid=wx51098e5dde0bafde&secret=a43810558f270074b2d3b3c2beab5897&code="+code+"&grant_type=authorization_code"
    response = Net::HTTP.get_response(URI(url))
    uuu=JSON.parse response.body
    uuu["openid"]
  end
  def response_msg
    wx_message_type = params[:xml][:MsgType]

    case wx_message_type
      when 'text'
        reply_text(params[:xml][:FromUserName], params[:xml][:ToUserName], params[:xml][:Content])
      when 'event'
        handle_weixin_event(params[:xml][:FromUserName], params[:xml][:ToUserName], params[:xml][:Event])
      else
        render :text => "not handled message type"
    end
  end

  def handle_weixin_event(from_user, to_user, event)
      reply = nil
      case event
          when 'subscribe'
            #reply = build_text_reply(from_user, to_user,
            #          '你好，感谢您关注：慢烧网。我们将竭诚予您服务' +
            #          '回复ms(大小写均可)，一起进入慢烧生活。        回复：gs(大小写均可),一起进入食材故事。')
          reply=build_image_reply(from_user,to_user,"MS")
      end
      reply.nil? ? render(:nothing => true) : render(:text => reply)
  end

  def reply_text(from_user, to_user, content)
    reply = nil
    case content
      when '慢烧','ms','MS'
        reply = build_image_reply(from_user, to_user,"MS")
      when '帮助','q',"Q"
        reply = build_text_reply(from_user, to_user,
                                     "1.回复任意数字或字母\r\n" +
                                     "2.点击大图进入点餐首页\r\n" +
                                     "3.选择送餐地址\r\n" +
                                     "4.将喜爱的餐食加入购物车或立即购买\r\n" +
                                     "5.选择送餐时间并选择付款方式\r\n" +
                                     "6.提交订单，并保持电话畅通\r\n" +
                                     "7.餐食将在30-40分钟左右送达\r\n\r\n" +
                                      "<a href='http://www.manshao.com'>马上去体验下最新潮的订餐方式带给你的惊喜吧！</a>" +
                                     "")
      else
        reply = build_image_reply(from_user, to_user,"MS")
    end
		reply.nil? ? render(:nothing => true) : render(:text => reply)
  end

  def build_text_reply(to_user, from_user, content)
    textTpl='<xml>'+
  		'<ToUserName><![CDATA['+to_user+']]></ToUserName>'+
  		'<FromUserName><![CDATA['+from_user+']]></FromUserName>'+
  		'<CreateTime>'+Time.now.to_s+'</CreateTime>'+
  		'<MsgType><![CDATA['+'text'+']]></MsgType>'+
  		'<Content><![CDATA['+content+']]></Content>'+
  		'<FuncFlag>0</FuncFlag>'+
  		'</xml>'
  end

  def reply_location
  end

  def build_image_reply(to_user, from_user,str)
      base = "#{request.scheme}://#{request.server_name}:#{request.server_port}";
      diancan_pic_url = base+'/weixin/manshao_big1.jpg'
      yichixia_pic_url =  base+'/weixin/manshao_small1.jpg'
      big_pic_words= '行走的美食，为你而来'
      small_pic_words ='点击图片进入首页点餐'
      url =  base+'/weixin/login?weixin_openid=' + to_user

    textTpl='<xml>'+
    		  '<ToUserName><![CDATA['+to_user+']]></ToUserName>'+
    			'<FromUserName><![CDATA['+from_user+']]></FromUserName>'+
    			'<CreateTime>'+Time.now.to_s+'</CreateTime>'+
    			'<MsgType><![CDATA[news]]></MsgType>'+
    			'<Content><![CDATA[]]></Content>'+
    			'<ArticleCount>2</ArticleCount>'+
    				'<Articles>'+
    					 '<item>'+
    					    '<Title><![CDATA['+big_pic_words +']]></Title>'+
    					    '<Description><![CDATA[description]]></Description>'+
    					    '<PicUrl><![CDATA['+diancan_pic_url+']]></PicUrl>'+
    					    '<Url><![CDATA['+url+']]></Url>'+
    					 '</item>'+
    					 '<item>'+
    					    '<Title><![CDATA['+small_pic_words+']]></Title>'+
    					    '<Description><![CDATA[description]]></Description>'+
    					    '<PicUrl><![CDATA['+yichixia_pic_url+']]></PicUrl>'+
    					    '<Url><![CDATA['+url+']]></Url>'+
    					 '</item>'+
    				'</Articles>'+
    			'<FuncFlag>1</FuncFlag>'+
    			'</xml> '
  end

  #检查是否是微信1chi应用端发过来的信息
  def check_signature
    signature=params[:signature]
    wx_token='xxxxxxuser-defined'
    timestamp=params[:timestamp]
    nonce=params[:nonce]
    tmp_str=sha1_encode(wx_token,timestamp,nonce)
    if tmp_str==signature
      return true
    else
      return false
    end
  end

  #sha1加密，请传wx_token,timestamp,nonce参数
  def sha1_encode(wx_token,timestamp,nonce)
    tmp_arr=[wx_token,timestamp,nonce]
    tmp_arr=tmp_arr.sort
    tmp_arr_str=tmp_arr[0]+tmp_arr[1]+tmp_arr[2]
    tmp_str=Digest::SHA1.hexdigest(tmp_arr_str)
    return tmp_str
  end
end

