<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<%
' *** Logout the current user.
MM_Logout = CStr(Request.ServerVariables("URL")) & "?MM_Logoutnow=1"
If (CStr(Request("MM_Logoutnow")) = "1") Then
  Session.Contents.Remove("MM_Username")
  Session.Contents.Remove("MM_UserAuthorization")
  MM_logoutRedirectPage = "login.asp"
  ' redirect with URL parameters (remove the "MM_Logoutnow" query param).
  if (MM_logoutRedirectPage = "") Then MM_logoutRedirectPage = CStr(Request.ServerVariables("URL"))
  If (InStr(1, UC_redirectPage, "?", vbTextCompare) = 0 And Request.QueryString <> "") Then
    MM_newQS = "?"
    For Each Item In Request.QueryString
      If (Item <> "MM_Logoutnow") Then
        If (Len(MM_newQS) > 1) Then MM_newQS = MM_newQS & "&"
        MM_newQS = MM_newQS & Item & "=" & Server.URLencode(Request.QueryString(Item))
      End If
    Next
    if (Len(MM_newQS) > 1) Then MM_logoutRedirectPage = MM_logoutRedirectPage & MM_newQS
  End If
  Response.Redirect(MM_logoutRedirectPage)
End If
%>
<!--#include file="../Connections/CapexConn.asp" -->
<%

Dim Jabatan__userID
Jabatan__userID = ""
if(Session("UpdateUsr") <> "") then Jabatan__userID = Session("UpdateUsr")

%>
<%

Dim UpdateCapexAppr__Nocapex
UpdateCapexAppr__Nocapex = ""
if(Request("Nocapex") <> "") then UpdateCapexAppr__Nocapex = Request("Nocapex")

Dim UpdateCapexAppr__userID
UpdateCapexAppr__userID = ""
if(Session("UpdateUsr") <> "") then UpdateCapexAppr__userID = Session("UpdateUsr")

%>
<%
Dim rsCapexHD__MMColParam
rsCapexHD__MMColParam = "1"
If (Request.QueryString("NoCapex") <> "") Then 
  rsCapexHD__MMColParam = Request.QueryString("NoCapex")
End If
%>

<%
Dim rsCapexHD
Dim rsCapexHD_numRows

Set rsCapexHD = Server.CreateObject("ADODB.Recordset")
rsCapexHD.ActiveConnection = MM_CapexConn_STRING
rsCapexHD.Source = "SELECT NoCapex  FROM dbo.CapexHD  WHERE NoCapex = '" + Replace(rsCapexHD__MMColParam, "'", "''") + "'"
rsCapexHD.CursorType = 0
rsCapexHD.CursorLocation = 2
rsCapexHD.LockType = 1
rsCapexHD.Open()

rsCapexHD_numRows = 0
%>
<%

set Jabatan = Server.CreateObject("ADODB.Command")
Jabatan.ActiveConnection = MM_CapexConn_STRING
Jabatan.CommandText = "dbo.P_Ambiljabatan"
Jabatan.Parameters.Append Jabatan.CreateParameter("@RETURN_VALUE", 3, 4)
Jabatan.Parameters.Append Jabatan.CreateParameter("@userID", 200, 1,20,Jabatan__userID)
Jabatan.Parameters.Append Jabatan.CreateParameter("@JabatanID", 200, 2,20)
Jabatan.CommandType = 4
Jabatan.CommandTimeout = 0
Jabatan.Prepared = true
Jabatan.Execute()

%>
<%

set UpdateCapexAppr = Server.CreateObject("ADODB.Command")
UpdateCapexAppr.ActiveConnection = MM_CapexConn_STRING
UpdateCapexAppr.CommandText = "dbo.P_UpdateCapexApproval"
UpdateCapexAppr.Parameters.Append UpdateCapexAppr.CreateParameter("@RETURN_VALUE", 3, 4)
UpdateCapexAppr.Parameters.Append UpdateCapexAppr.CreateParameter("@Nocapex", 200, 1,20,UpdateCapexAppr__Nocapex)
UpdateCapexAppr.Parameters.Append UpdateCapexAppr.CreateParameter("@userID", 200, 1,20,UpdateCapexAppr__userID)
UpdateCapexAppr.CommandType = 4
UpdateCapexAppr.CommandTimeout = 0
UpdateCapexAppr.Prepared = true
UpdateCapexAppr.Execute()

%>
<%
' *** Validate request to log in to this site.
MM_LoginAction = Request.ServerVariables("URL")
If Request.QueryString<>"" Then MM_LoginAction = MM_LoginAction + "?" + Request.QueryString
MM_valUsername=CStr(Request.Form("NoCapex"))
If MM_valUsername <> "" Then
  MM_fldUserAuthorization=""
  MM_redirectLoginSuccess="Confirmapproval.asp"
  MM_redirectLoginFailed="Infocapexappr.asp"
  MM_flag="ADODB.Recordset"
  set MM_rsUser = Server.CreateObject(MM_flag)
  MM_rsUser.ActiveConnection = MM_CapexConn_STRING
  MM_rsUser.Source = "SELECT NoCapex, NoCapex"
  If MM_fldUserAuthorization <> "" Then MM_rsUser.Source = MM_rsUser.Source & "," & MM_fldUserAuthorization
  MM_rsUser.Source = MM_rsUser.Source & " FROM dbo.CapexAppr WHERE NoCapex='" & Replace(MM_valUsername,"'","''") &"' AND NoCapex='" & Replace(Request.Form("NoCapex"),"'","''") & "'"
  MM_rsUser.CursorType = 0
  MM_rsUser.CursorLocation = 2
  MM_rsUser.LockType = 3
  MM_rsUser.Open
  If Not MM_rsUser.EOF Or Not MM_rsUser.BOF Then 
    ' username and password match - this is a valid user
    Session("MM_Username") = MM_valUsername
	Session("Updateno") = session("MM_Username")
    If (MM_fldUserAuthorization <> "") Then
      Session("MM_UserAuthorization") = CStr(MM_rsUser.Fields.Item(MM_fldUserAuthorization).Value)
    Else
      Session("MM_UserAuthorization") = ""
    End If
    if CStr(Request.QueryString("accessdenied")) <> "" And false Then
      MM_redirectLoginSuccess = Request.QueryString("accessdenied")
    End If
    MM_rsUser.Close
    Response.Redirect(MM_redirectLoginSuccess)
  End If
  MM_rsUser.Close
  Response.Redirect(MM_redirectLoginFailed)
End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>:: Capex Approval ::</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 18px}
.style2 {font-size: 36px}
.style3 {font-size: 16px}
body,td,th {
	color: #0000FF;
}
-->
</style>
<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);

function MM_displayStatusMsg(msgStr) { //v1.0
  status=msgStr;
  document.MM_returnValue = true;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<link href="../css/style.css" rel="stylesheet" type="text/css">


</head>

<body background="../Image/bgact.gif" onLoad="MM_displayStatusMsg('Capex Approval ');return document.MM_returnValue;MM_preloadImages('../Image/CreateCapex_on.gif','../Image/ApprovalCapex_on.gif','../Image/CreateAOC_on.gif','../Image/Approvalaoc_on.gif','../Image/holdcapex_on.gif','../Image/holdAoc_on.gif','../Image/Estimation_on.gif','../Image/Actual_on.gif')">
<div align="center"> 
  <div align="center"> 
    <div align="center"> 
      <div align="center"> 
        <div align="center"> 
          <div align="center"> 
            <div align="center"> 
              <table width="800" border="1" align="center" bordercolor="#006600">
                <tr bordercolor="#006600"> 
                  <td colspan="2"> <div align="left"><img src="../Image/sieradonline.gif" width="222" height="85"> 
                    </div>
                    <div align="right"><font color="#006600">Date : 
                      <script name="current" src="../../GeneratedItems/current.js" language="JavaScript1.2"></script>
                      </font></div></td>
                </tr>
                <tr bordercolor="#006600" bgcolor="#CCCCCC"> 
                  <td> <div align="left"><font color="#006600">Welcome <%= Session("UpdateUsr") %></font></div></td>
                  <td width="300"> <div align="center"><font color="#009900"><a href="../contact.asp"><font color="#006600">Hubungi 
                      Kami</font></a></font><font color="#FF0000">&nbsp; </font>| 
                      <a href="../karir.asp"><font color="#006600">Karir </font></a>| 
                      <a href="../link.asp"><font color="#006600">Links </font></a>| 
                      <a href="<%= MM_Logout %>"><font color="#006600">Log Out</font></a></div></td>
                </tr>
              </table>
              <table width="800" border="0" align="center" bordercolor="#FF6600" bgcolor="#006600">
                <tr> 
                  <td><div align="center"><img src="../../BREEDING/img/spacer.gif" width="795" height="10"></div></td>
                </tr>
              </table>
              <table width="800" border="1" align="center" bordercolor="#CCCCCC" bgcolor="#006600">
                <tr> 
                  <td width="150" height="23"><div align="center"><a href="createcapex.asp" onMouseOver="MM_swapImage('Image1','','../Image/CreateCapex_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/CreateCapex.gif" name="Image1" width="150" height="23" border="0" id="Image1"></a></div></td>
                  <td width="330" rowspan="8" bgcolor="#006600"><div align="center"> 
                      <p> 
                        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" width="323" height="122" align="top">
                          <param name="movie" value="../Animasi/anakayam.swf">
                          <param name="quality" value="high">
                          <param name="SCALE" value="exactfit">
                          <embed src="../Animasi/anakayam.swf" width="323" height="122" align="top" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" scale="exactfit"></embed></object>
                      </p>
                      <p>&nbsp;</p>
                      <p>&nbsp;</p>
                      <p>&nbsp;</p>
                      <p>&nbsp; </p>
                    </div></td>
                  <td width="296"><div align="right"><font color="#FFFFFF">Time 
                      : <strong><%=time()%></strong></font></div></td>
                </tr>
                <tr> 
                  <td><div align="center"><a href="Infocapexappr.asp" onMouseOver="MM_swapImage('Image2','','../Image/ApprovalCapex_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/ApprovalCapex.gif" name="Image2" width="150" height="23" border="0" id="Image2"></a></div></td>
                  <td rowspan="7"><div align="left"> 
                      <p>&nbsp;</p>
                      <p>&nbsp;</p>
                    </div></td>
                </tr>
                <tr> 
                  <td><div align="center"><a href="ListCapexApproved.asp" onMouseOver="MM_swapImage('Image3','','../Image/CreateAOC_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/CreateAOC.gif" name="Image3" width="150" height="23" border="0" id="Image3"></a></div></td>
                </tr>
                <tr> 
                  <td><div align="center"><a href="InfoAOCappr.asp" onMouseOver="MM_swapImage('Image4','','../Image/Approvalaoc_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/Approvalaoc.gif" name="Image4" width="150" height="23" border="0" id="Image4"></a></div></td>
                </tr>
                <tr> 
                  <td height="16"> <div align="center"><a href="hold%20capex.asp" onMouseOver="MM_swapImage('Image5','','../Image/holdcapex_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/holdcapex.gif" name="Image5" width="150" height="23" border="0" id="Image5"></a></div></td>
                </tr>
                <tr> 
                  <td height="24"><a href="hold%20AOC.asp" onMouseOver="MM_swapImage('Image6','','../Image/holdAoc_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/holdAoc.gif" name="Image6" width="150" height="23" border="0" id="Image6"></a></td>
                </tr>
                <tr> 
                  <td height="24"><a href="SearchNoAOCforPayment.asp" onMouseOver="MM_swapImage('Image7','','../Image/Estimation_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/Estimation.gif" name="Image7" width="150" height="23" border="0" id="Image7"></a></td>
                </tr>
                <tr> 
                  <td height="27"> <div align="center"><a href="Payman%20actual.asp" onMouseOver="MM_swapImage('Image8','','../Image/Actual_on.gif',1)" onMouseOut="MM_swapImgRestore()"><img src="../Image/Actual.gif" name="Image8" width="150" height="23" border="0" id="Image8"></a></div></td>
                </tr>
              </table>
              <table width="800" border="0" align="center" bordercolor="#FF6600" bgcolor="#006600">
                <tr> 
                  <td><div align="center"><img src="../../BREEDING/img/spacer.gif" width="795" height="10"></div></td>
                </tr>
              </table>
              <table width="806" border="0" align="center" background="../../img/bg.gif">
                <tr> 
                  <td width="800" height="20"><div align="left"><font color="#FF0000" size="3" face="Courier New, Courier, mono">&gt;&gt; 
                      <strong>CAPEX</strong></font></div></td>
                </tr>
                <tr> 
                  <td><div align="left"><img src="../Image/spacer.jpg" width="200" height="2"></div></td>
                </tr>
                <tr> 
                  <td height="215"> <div align="center"> 
                      <table width="800" border="0">
                        <tr> 
                          <td height="3"> <div align="center"><img src="../../img/garis1.gif" width="600" height="1"></div></td>
                        </tr>
                      </table>
                      <p><img src="../../img/garis1.gif" width="400" height="1"></p>
                      <form METHOD="POST" action="<%=MM_LoginAction%>" name="form1">
                        <table width="46%" border="1" bgcolor="#CCCCCC">
                          <tr> 
                            <td width="28%"><div align="right">No Capex *</div></td>
                            <td width="72%"> <div align="left"> 
                                <input name="NoCapex"   readonly="text" id="NoCapex2" value="<%=(rsCapexHD.Fields.Item("NoCapex").Value)%>">
                              </div></td>
                          </tr>
                          <tr> 
                            <td><div align="right">User ID *</div></td>
                            <td><div align="left"> 
                                <input name="userid" readonly="text" id="userid2" value="<%=session ("UpdateUsr") %>">
                              </div></td>
                          </tr>
                          <tr> 
                            <td><div align="right">Jabatan ID *</div></td>
                            <td> <div align="left"> 
                                <input name="jbtn" readonly="text" id="jbtn2" value="<%= Jabatan.Parameters.Item("@JabatanID").Value %>">
                              </div></td>
                          </tr>
                          <tr> 
                            <td><div align="right">Tanggal Approval *</div></td>
                            <td> <div align="left"> 
                                <input name="date" readonly="text" id="date2" value="<%=date%>">
                              </div></td>
                          </tr>
                          <tr> 
                            <td height="28"> <div align="center"> 
                                <input type="submit" name="Submit" value="Submit">
                              </div></td>
                            <td><div align="right"><font color="#663300"> 
                                <input name="hiddenField" type="hidden" value="<%= Session("UpdateUsr") %>">
                                Tanggal <%=date%></font></div></td>
                          </tr>
                        </table>
                      </form>
                      <p><img src="../../img/garis1.gif" width="400" height="1"></p>
                    </div></td>
                </tr>
                <tr> 
                  <td><div align="center"><img src="../../img/garis1.gif" width="600" height="1"></div></td>
                </tr>
                <tr> 
                  <td height="47"><div align="center"> 
                      <p>&nbsp;</p>
                      <table width="800" border="1" bordercolor="#FF6600">
                        <tr> 
                          <td><div align="center"><font color="#009900"><font color="#006600">-- 
                              HOME</font></font><font color="#006600">&nbsp; </font>| 
                              <a href="Sman.asp"><font color="#006600">SYSTEM 
                              MANAGER</font></a><font color="#006600"> </font>| 
                              <a href="Activity.asp"><font color="#006600">ACTIVITIES</font></a><font color="#006600"> 
                              </font>|<a href="../Reports/reportListing.asp"> 
                              <font color="#006600">REPORT</font></a><font color="#006600"> 
                              | FAQ --</font></div></td>
                        </tr>
                      </table>
                      <p><img src="../Image/bannerrg.jpg" width="800" height="20"></p>
                    </div></td>
                </tr>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
</div>
</body>
</html>
<%
rsCapexHD.Close()
Set rsCapexHD = Nothing
%>
