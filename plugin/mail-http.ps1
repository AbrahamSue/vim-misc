$time = get-date 

$from    = 'dichotomy6@gmail.com'
$to      = 'cyankindle66@gmail.com'
$subject = 'eMail-HTML ' + $time

$server=smtp.gmail.com;$port=587

$encoding = [System.Text.Encoding]::UTF8

$email=new-object Net.Mail.MailMessage($from, $to, $subject, $body)
$email.DeliveryNotificationOptions=[System.Net.Mail.DeliveryNotificationOptions]::Delay
$email.IsBodyHtml = $true
$email.Priority = [System.Net.Mail.MailPriority]::High

$email.BodyEncoding=$encoding

$email.Body = gc '.\HTML-eMail.html' -encoding UTF8

$smtp=new-object Net.Mail.SmtpClient($server,$port)
$smtp.EnableSSL = $true
$smtp.Timeout = 30000  #ms
$smtp.Credentials=New-Object System.Net.NetworkCredential($from, 'derParol'); 

$smtp.Send($email)

