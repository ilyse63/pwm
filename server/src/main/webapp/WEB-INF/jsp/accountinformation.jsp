<%--
  ~ Password Management Servlets (PWM)
  ~ http://www.pwm-project.org
  ~
  ~ Copyright (c) 2006-2009 Novell, Inc.
  ~ Copyright (c) 2009-2017 The PWM Project
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or
  ~ (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  --%>

<%@ page import="password.pwm.bean.LocalSessionStateBean" %>
<%@ page import="password.pwm.bean.ResponseInfoBean" %>
<%@ page import="password.pwm.ldap.UserInfo" %>
<%@ page import="password.pwm.config.value.data.FormConfiguration" %>
<%@ page import="password.pwm.config.PwmSetting" %>
<%@ page import="password.pwm.config.option.ViewStatusFields" %>
<%@ page import="password.pwm.http.JspUtility" %>
<%@ page import="password.pwm.http.PwmRequestAttribute" %>
<%@ page import="password.pwm.http.servlet.PwmServletDefinition" %>
<%@ page import="password.pwm.http.servlet.command.CommandServlet" %>
<%@ page import="password.pwm.i18n.Display" %>
<%@ page import="password.pwm.svc.event.UserAuditRecord" %>
<%@ page import="password.pwm.util.LocaleHelper" %>
<%@ page import="password.pwm.util.java.JavaHelper" %>
<%@ page import="password.pwm.util.java.StringUtil" %>
<%@ page import="password.pwm.util.java.TimeDuration" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<!DOCTYPE html>
<%@ page language="java" session="true" isThreadSafe="true" contentType="text/html" %>
<%@ taglib uri="pwm" prefix="pwm" %>
<%
    final PwmRequest userinfo_pwmRequest = JspUtility.getPwmRequest(pageContext);
    final UserInfo userInfo = JspUtility.getPwmRequest(pageContext).getPwmSession().getUserInfo();
    final LocalSessionStateBean ssBean = userinfo_pwmRequest.getPwmSession().getSessionStateBean();
    final Set<ViewStatusFields> viewStatusFields = userinfo_pwmRequest.getConfig().readSettingAsOptionList(PwmSetting.ACCOUNT_INFORMATION_VIEW_STATUS_VALUES,ViewStatusFields.class);
    List<UserAuditRecord> auditRecords = Collections.emptyList();
    try {
        auditRecords = userinfo_pwmRequest.getPwmApplication().getAuditManager().readUserHistory(userinfo_pwmRequest.getPwmSession());
    } catch (Exception e) {
    /*noop*/
    }
    final Locale userLocale = userinfo_pwmRequest.getLocale();
%>

<html lang="<pwm:value name="<%=PwmValue.localeCode%>"/>" dir="<pwm:value name="<%=PwmValue.localeDir%>"/>">
<%@ include file="/WEB-INF/jsp/fragment/header.jsp" %>
<body class="nihilo">
<div id="wrapper" class="nihilo">
<jsp:include page="/WEB-INF/jsp/fragment/header-body.jsp">
    <jsp:param name="pwm.PageName" value="Title_UserInformation"/>
</jsp:include>
<div id="centerbody">
<div id="page-content-title" style="display: none;"><pwm:display key="Title_UserInformation" displayIfMissing="true"/></div>
<div data-dojo-type="dijit.layout.TabContainer" style="width: 100%; height: 100%;" data-dojo-props="doLayout: false">
<div data-dojo-type="dijit.layout.ContentPane" id="UserInformation" title="<pwm:display key="Title_UserInformation"/>" class="tabContent">
    <table class="nomargin">
        <% if (viewStatusFields.contains(ViewStatusFields.Username)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_Username"/>
            </td>
            <td id="Username">
                <%= StringUtil.escapeHtml(userInfo.getUsername()) %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.UserDN)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_UserDN"/>
            </td>
            <td id="UserDN">
                <%= StringUtil.escapeHtml(userInfo.getUserIdentity().getUserDN()) %>
            </td>
        </tr>
        <% if (userinfo_pwmRequest.getConfig().getLdapProfiles().size() > 1) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_LdapProfile"/>
            </td>
            <td id="LdapProfile">
                <%= StringUtil.escapeHtml(userinfo_pwmRequest.getConfig().getLdapProfiles().get(
                        userInfo.getUserIdentity().getLdapProfileID()).getDisplayName(
                        userinfo_pwmRequest.getLocale())) %>
            </td>
        </tr>
        <% } %>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.UserEmail)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_UserEmail"/>
            </td>
            <td id="userEmail">
                <% if (userInfo.getUserEmailAddress() == null) { %>
                <pwm:display key="Value_NotApplicable"/>
                <% } else { %>
                <%= StringUtil.escapeHtml(userInfo.getUserEmailAddress()) %>
                <% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.UserSMS)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_UserSMS"/>
            </td>
            <td id="UserSMS">
                <% if (userInfo.getUserSmsNumber() == null) { %>
                <pwm:display key="Value_NotApplicable"/>
                <% } else { %>
                <%= StringUtil.escapeHtml(userInfo.getUserSmsNumber()) %>
                <% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.GUID)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_UserGUID"/>
            </td>
            <td id="UserGUID">
                <%= StringUtil.escapeHtml(userInfo.getUserGuid()) %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.AccountExpirationTime)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_AccountExpirationTime"/>
            </td>
            <% if (userInfo.getAccountExpirationTime() == null) { %>
            <td id="AccountExpirationTime">
                <pwm:display key="Value_NotApplicable"/>
            </td>
            <% } else { %>
            <td class="timestamp" id="AccountExpirationTime">
                <%= JavaHelper.toIsoDate(userInfo.getAccountExpirationTime()) %>
            </td>
            <% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordExpired)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordExpired"/>
            </td>
            <td id="PasswordExpired">
                <%if (userInfo.getPasswordStatus().isExpired()) {%><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordPreExpired)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordPreExpired"/>
            </td>
            <td id="PasswordPreExpired">
                <%if (userInfo.getPasswordStatus().isPreExpired()) {%><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordWarnPeriod)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordWithinWarningPeriod"/>
            </td>
            <td id="PasswordWithinWarningPeriod">
                <%if (userInfo.getPasswordStatus().isWarnPeriod()) { %><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordViolatesPolicy)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordViolatesPolicy"/>
            </td>
            <td id="PasswordViolatesPolicy">
                <% if (userInfo.getPasswordStatus().isViolatesPolicy()) {%><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordSetTime)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordSetTime"/>
            </td>
            <% if (userInfo.getPasswordLastModifiedTime() == null) { %>
            <td  id="PasswordSetTime">
                <pwm:display key="Value_NotApplicable"/>
            </td>
            <% } else { %>
            <td class="timestamp"  id="PasswordSetTime">
                <%= JavaHelper.toIsoDate(userInfo.getPasswordLastModifiedTime()) %>
            </td>
            <% } %>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.PasswordSetTimeDelta)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordSetTimeDelta"/>
            </td>
            <td id="PasswordSetTimeDelta">
                <%= userInfo.getPasswordLastModifiedTime() != null
                        ? TimeDuration.fromCurrent(userInfo.getPasswordLastModifiedTime()).asLongString(ssBean.getLocale())
                        : LocaleHelper.getLocalizedMessage(Display.Value_NotApplicable, userinfo_pwmRequest)
                %>
            </td>
        </tr>
        <tr>
            <td class="key">
                <pwm:display key="Field_PasswordExpirationTime"/>
            </td>
            <% if (userInfo.getPasswordExpirationTime() == null) { %>
            <td id="PasswordExpirationTime">
                <pwm:display key="Value_NotApplicable"/>
            </td>
            <% } else { %>
            <td class="timestamp" id="PasswordExpirationTime">
                <%= JavaHelper.toIsoDate(userInfo.getPasswordExpirationTime()) %>
            </td>
            <% } %>
        </tr>
        <% } %>
        <% final ResponseInfoBean responseInfoBean = userinfo_pwmRequest.getPwmSession().getUserInfo().getResponseInfoBean(); %>
        <% if (viewStatusFields.contains(ViewStatusFields.ResponsesStored)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_ResponsesStored"/>
            </td>
            <td id="ResponsesStored">
                <%if (!userInfo.isRequiresResponseConfig()) { %><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.ResponsesTimestamp)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_ResponsesTimestamp"/>
            </td>
            <% if (responseInfoBean == null || responseInfoBean.getTimestamp() == null ) { %>
            <td id="ResponsesTimestamp">
                <pwm:display key="Value_NotApplicable"/>
            </td>
            <% } else { %>
            <td class="timestamp" id="ResponsesTimestamp">
                <%= JavaHelper.toIsoDate(responseInfoBean.getTimestamp()) %>
            </td>
            <% } %>
        </tr>
        <% } %>
        <pwm:if test="<%=PwmIfTest.otpEnabled%>">
            <% if (viewStatusFields.contains(ViewStatusFields.OTPStored)) { %>
            <tr>
                <td class="key">
                    <pwm:display key="Field_OTP_Stored"/>
                </td>
                <td id="OTP_Stored">
                    <%if (userInfo.getOtpUserRecord() != null) {%><pwm:display key="Value_True"/><% } else { %><pwm:display key="Value_False"/><% } %>
                </td>
            </tr>
            <% } %>
            <% if (viewStatusFields.contains(ViewStatusFields.OTPTimestamp)) { %>
            <tr>
                <td class="key">
                    <pwm:display key="Field_OTP_Timestamp"/>
                </td>
                <% if (userInfo.getOtpUserRecord() == null || userInfo.getOtpUserRecord().getTimestamp() == null) { %>
                <td id="OPT_Timestamp">
                    <pwm:display key="Value_NotApplicable"/>
                </td>
                <% } else { %>
                <td class="timestamp" id="OPT_Timestamp">
                    <%= JavaHelper.toIsoDate(userInfo.getOtpUserRecord().getTimestamp()) %>
                </td>
                <% } %>
            </tr>
            <% } %>
        </pwm:if>
        <% if (viewStatusFields.contains(ViewStatusFields.NetworkAddress)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_NetworkAddress"/>
            </td>
            <td id="NetworkAddress">
                <%= ssBean.getSrcAddress() %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.NetworkHost)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_NetworkHost"/>
            </td>
            <td id="NetworkHost">
                <%= ssBean.getSrcHostname() %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.LogoutURL)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_LogoutURL"/>
            </td>
            <td id="LogoutURL">
                <%= StringUtil.escapeHtml(userinfo_pwmRequest.getLogoutURL()) %>
            </td>
        </tr>
        <% } %>
        <% if (viewStatusFields.contains(ViewStatusFields.ForwardURL)) { %>
        <tr>
            <td class="key">
                <pwm:display key="Field_ForwardURL"/>
            </td>
            <td id="ForwardURL">
                <%= StringUtil.escapeHtml(userinfo_pwmRequest.getForwardUrl()) %>
            </td>
        </tr>
        <% } %>
    </table>
</div>
<% final Map<FormConfiguration, List<String>> userFormData = (Map<FormConfiguration,List<String>>)JspUtility.getAttribute(pageContext, PwmRequestAttribute.FormData); %>
<% if (userFormData != null && !userFormData.isEmpty()) { %>
<div data-dojo-type="dijit.layout.ContentPane" id="UserData" title="<pwm:display key="<%=Display.Title_UserData.toString()%>"/>" class="tabContent">
    <div style="max-height: 400px; overflow: auto;">
        <table class="nomargin">
            <% for (final FormConfiguration formConfiguration : userFormData.keySet()) { %>
            <tr>
                <td class="key" style="width:50%">
                    <span class="timestamp">
                    <%= formConfiguration.getLabel(userLocale) %>
                    </span>
                </td>
                <td>
                    <% for (final String value : userFormData.get(formConfiguration)) { %>
                    <%=  StringUtil.escapeHtml(value) %><br/>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</div>
<% } %>



    <div data-dojo-type="dijit.layout.ContentPane" id="PasswordPolicy" title="<pwm:display key="Title_PasswordPolicy"/>" class="tabContent">
    <div style="max-height: 400px; overflow: auto;">
        <table class="nomargin">
            <tr>
                <td class="key">
                    <pwm:display key="Title_PasswordPolicy"/>
                </td>
                <td id="PasswordRequirments">
                    <ul>
                        <pwm:DisplayPasswordRequirements separator="</li>" prepend="<li>"/>
                    </ul>
                </td>
            </tr>
        </table>
    </div>
</div>
<% if (userinfo_pwmRequest != null && ContextManager.getPwmApplication(session).getConfig().readSettingAsBoolean(PwmSetting.ACCOUNT_INFORMATION_HISTORY)) { %>
<% if (auditRecords != null && !auditRecords.isEmpty()) { %>
<div data-dojo-type="dijit.layout.ContentPane" id="UserEventHistory" title="<pwm:display key="Title_UserEventHistory"/>" class="tabContent">
    <div style="max-height: 400px; overflow: auto;">
        <table class="nomargin">
            <% for (final UserAuditRecord record : auditRecords) { %>
            <tr>
                <td class="key" style="width:50%">
                            <span class="timestamp">
                            <%= JavaHelper.toIsoDate(record.getTimestamp()) %>
                            </span>
                </td>
                <td>
                    <%= record.getEventCode().getLocalizedString(ContextManager.getPwmApplication(session).getConfig(),userLocale) %>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</div>
<% } %>
<% } %>
</div>
<div class="buttonbar">
    <form action="<pwm:url url='<%=PwmServletDefinition.PublicCommand.servletUrl()%>' addContext="true"/>" method="post" enctype="application/x-www-form-urlencoded">
        <input type="hidden" name="<%=PwmConstants.PARAM_ACTION_REQUEST%>" value="<%=CommandServlet.CommandAction.next.toString()%>"/>
        <input type="hidden" id="pwmFormID" name="pwmFormID" value="<pwm:FormID/>"/>
        <button type="submit" name="button" class="btn" id="button_continue">
            <pwm:if test="<%=PwmIfTest.showIcons%>"><span class="btn-icon pwm-icon pwm-icon-forward"></span></pwm:if>
            <pwm:display key="Button_Continue"/>
        </button>
    </form>
</div>
</div>
<div class="push"></div>
</div>
<pwm:script>
<script type="text/javascript">
    PWM_GLOBAL['startupFunctions'].push(function(){
        require(["dojo/parser","dijit/layout/TabContainer","dijit/layout/ContentPane"],function(dojoParser){
            dojoParser.parse();
        });
    });
</script>
</pwm:script>
<jsp:include page="/WEB-INF/jsp/fragment/footer.jsp"/>
</body>
</html>                   
