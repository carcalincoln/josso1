<%@ page pageEncoding="UTF-8" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@page import="admApli.Configuracion"%>
<%@page language="java"  errorPage="/Error.jsp"%>

<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
<head>
	<c:remove var="usuario" scope="session" />
	<script type="text/javascript" src="<%=admApli.Path.getRecurso()%>/script/comun/teclado.js" >
	</script>
	<meta name="volver" content="/">
	<title>Login</title>
	
	<html:javascript formName="usernamePasswordLoginForm" staticJavascript="false" />
</head>
<body id="login">
    <div id="login" >
		<html:form action="/signon/usernamePasswordLogin" focus="josso_username"  styleClass="formulario" method="get" onsubmit="return validateUsernamePasswordLoginForm(this);">
			<html:hidden property="<%=org.josso.gateway.signon.Constants.PARAM_JOSSO_CMD %>" value="login"/>
			<html:hidden property="RPBAExterno" value="externo"/>
			<div class="titulo">
				Portal de Servicios para Usuarios Suscriptos
			</div>
			<table class="formulario">
				<tr>
					<td class="nombreFormulario"> 
						Usuario
					</td>
					<td class="separadorCampoFormulario">
						:
					</td>
					<td class="campoFormulario"> 
						<html:text  property="josso_username"  size="10" maxlength="10" tabindex="1"  value=""/>
					</td>
				</tr>
				<tr> 
					<td class="nombreFormulario"> 
						Contraseña
					</td>
					<td class="separadorCampoFormulario">
						:
					</td>
					<td class="campoFormulario"> 
						<html:password property="josso_password" styleId="josso_password"  size="10" maxlength="10" tabindex="2" redisplay="false"/>
					</td>
				</tr>
			</table>
			<div id="botonera">
				<input name="enviar" type="submit" tabindex="5" value="Enviar" size="20"/>
			</div>
			<hr/>
			<div>
				<div id="botones" style="display:none;">
				</div>
				<script>
					var letras="";
					var p=0;
					for (a=0;a<Tletras.length;a++){
						letras=letras+"<input  type='Button' value="+Tletras[a]+" onclick=anadir('"+Tletras[a]+"','josso_password')>&nbsp;";
						p=p+1;
						if(p==10){
							p=0;
							letras=letras+"<br><br>";
						}
					}
					var botones =document.getElementById("botones");
					botones.innerHTML=letras+"<input alt='Borrar' type='Button' value='Borrar' onClick=anadir('<<','josso_password')><br><input type='Button' value='Espacio' onclick=anadir('&#160','josso_password')><input alt='Limpiar' type='Button' value='Limpiar' onClick=anadir('!!','josso_password')><br></br><input type='checkbox' name='mayusculas' onclick='cambiomayus(this)' checked>Mayusculas";
				</script>
				<a id="pregunta" href="javascript:mostrar()">Mostrar teclado</a><br/>
			</div>
		</html:form>
		<a href="<%=request.getContextPath()%>/selfservices/lostpassword/lostPassword.do?josso_cmd=lostPwd&RPBAExterno=1">Olvidé mi contraseña / Usuario bloqueado</a>
	</div>
	<script type="JavaScript">
		anadir('!!','josso_password');
	</script>
	<div class="mensaje">
		Sr. Escribano: Para activar su cuenta en el nuevo portal, por unica vez, haga click <a href='<%=admApli.Path.getRecurso()+"/admUsuario/activacion/jsp/habilitar.jsp" %>'>aqui</a>
	</div>
</body>
</html>