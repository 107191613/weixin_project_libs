#######################微信支付start#########################################################
  def wx_payment
    @out_trade_no="16642817866003386000"     #商户订单号      #需要传来的值
    @total_fee="1"                           #订单总金额      #需要传来的值
    partner="1900000109"                     #商户号财付通ID
    paternerKey="8934e7d15453e97507ef794cf7b0519d"  #商户号权限密钥
    @appId="wxf8b4f85f3a794e77"              #appId
    appKey="2Wozy2aksie1puXUBpWD8oZxiD1DfQuEaiC7KcRATv1Ino3mdopKaPGQQ7TtkNySuAmCaDCrw4xhPY5qKTBl7Fzm0RgR3c0WaVYIXZARsxzHV2x7iwPPzOz94dnwPWSn"
    @timeStamp="189026618"     #时间戳
    @nonceStr="adssdasssd13d"  #字符串#####验证唯一#####
    string1=get_string1 @out_trade_no,@total_fee,partner
    p "-------------string1------------"
    p string1
    stringSignTemp=string1+"&key="+paternerKey
    @sign=md5_upperCase stringSignTemp
    @package=string1.gsub(":","%3a").gsub("/","%2f")+"&sign="+@sign
    string2=get_string2 @appId,appKey,@package,@timeStamp,@nonceStr
    p "-------------string2------------"
    p string2
    @paySign=SHA1_encrypt string2
    session[:wp_out_trade_no]= @out_trade_no
    session[:wp_nonceStr]= @nonceStr
    session[:wp_total_fee]= @total_fee
    #然后页面调用JS支付下面这段需要写在view里面
  end

  #传入 商户订单号 订单总金额
  def get_string1 out_trade_no,total_fee,partner
    bank_type="WX"#固定字符
    body="慢烧订单支付"    #商品描述
    fee_type="1"  #支付类型
    input_charset="UTF-8"    #字符编码
    #input_charset="GBK"    #字符编码
    notify_url="#{request.scheme}://#{request.server_name}:#{request.server_port}"+"/weixin/wx_callback" #成功后通知页面
    #notify_url="http://www.qq.com" #成功后通知页面
    spbill_create_ip=request.remote_ip   #客户IP
    string1="bank_type="+bank_type+"&body="+body+"&fee_type="+fee_type+"&input_charset="+input_charset+
        "&notify_url="+notify_url+"&out_trade_no="+out_trade_no+"&partner="+partner+
        "&spbill_create_ip="+spbill_create_ip+"&total_fee="+total_fee
  end
  #传入appId,appKey,package
  def get_string2 appId,appKey,package,timeStamp,nonceStr
    string2="appid="+appId+"&appkey="+appKey+"&noncestr="+nonceStr+
        "&package="+package+"&timestamp="+timeStamp
  end

  def md5_upperCase str
    p "------------------MD5----------------"
    p Digest::MD5.hexdigest(str).upcase  #md5加密后转换成大写
  end
  def SHA1_encrypt str
    p "------------------SHA1---------------"
    p  Digest::SHA1.hexdigest(str)  #SHA1加密
  end

  #微信JS支付成功后的回调页面
  def wx_callback
    p "wx_callback"
    p params
  end

  def native_callback
    return "success"
    render json: "success"
  end
  def wq_notify
    return "success"
    render json: "success"
  end
  def alert_callback
    return "success"
    render json: "success"
  end
  #######################微信支付end###################################################
