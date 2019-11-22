<%@page contentType="text/html; charset=UTF-8" language="java"
	errorPage="/Error.jsp" import="admApli.*"
%>
<%@page import="admApli.Constantes"%>
<%@page import="admApli.modelo.Ambiente"%>
<%@page import="admApli.Path"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    Ambiente ambiente = (Ambiente) request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)) {
		response.sendRedirect(request.getAttribute("Host") + admApli.Configuracion.getString("DEFAULT_CONTEXT")	+ "/signon/login.do");
	}
%>
<html>
<head>
<c:remove var="usuario" scope="session" />
<script type="text/javascript" src="<%=admApli.Path.getRecurso()%>/script/comun/teclado.js">	
</script>
<meta name="volver" content="/" />
<title>Login</title>
<meta name="intranet" content="true" />
</head>
<body id="login">
	<div class="tituloSeccion">
		<a href="#"
			onClick="window.open('<%=Path.getRecurso()%>','window',toolbar='yes, location=no, directories=no, status=yes, menubar=no ,scrollbars=yes, resizable=no, left=0,top=0, WIDTH=800 HEIGHT=550');return false"
		>Página Institucional</a> | <a href="#"
			onClick="javascript:window.open('http://intradesa/servicios/portal/licencias.php','_self',toolbar='yes, location=no, directories=no, status=yes, menubar=no ,scrollbars=yes, resizable=no, left=0,top=0, WIDTH=800 HEIGHT=550');"
		> Formularios Personal</a> | <a href="#"
			onClick="window.open('http://app.siape.gba.gov.ar/Integracion','window',toolbar='yes, location=no, directories=no, status=yes, menubar=no ,scrollbars=yes, resizable=no, left=0,top=0, WIDTH=800 HEIGHT=550');return false"
		>SIAPEdigital</a>
		<!--| 
		<a href="#" onClick="window.open('http://babilonia/site/','window',toolbar='yes, location=no, directories=no, status=yes, menubar=no ,scrollbars=yes, resizable=no, left=0,top=0, WIDTH=800 HEIGHT=550');return false" title="Instructivos, Memorandos, Etc."> Digesto  </a-->
	</div>
	<div class="main">
		<html:messages id="errMsg">
			<li><p>
					<bean:write name="errMsg" />
				<p></li>
		</html:messages>
	</div>
	<div id="login">
		<html:form action="/signon/usernamePasswordLogin"
			focus="josso_username"
		>
			<html:hidden property="<%=org.josso.gateway.signon.Constants.PARAM_JOSSO_CMD %>" value="login"/>
			<html:hidden property="<%=org.josso.gateway.signon.Constants.PARAM_JOSSO_BACK_TO %>" value="/RegPropNew/signon/"/>
			<div class="titulo">Portal de Servicios para Usuarios Internos
			</div>
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">Usuario</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><html:text
							property="josso_username" size="10" maxlength="10" tabindex="1"
							value=""
						/></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Contraseña</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><html:password
							property="josso_password" styleId="josso_password" size="10"
							maxlength="10" tabindex="2" redisplay="false"
						/></td>
				</tr>
			</table>
			<div id="botonera">
				<input name="enviar" type="submit" tabindex="5" value="Enviar"
					size="20"
				/>
			</div>
			<hr />
			<div>
				<div id="botones" style="display: none;"></div>
				<script>
					var letras = "";
					var p = 0;
					for (a = 0; a < Tletras.length; a++) {
						letras = letras + "<input  type='Button' value=" + Tletras[a] + " onclick=anadir('" + Tletras[a] + "','josso_password')>&nbsp;";
						p = p + 1;
						if (p == 10) {
							p = 0;
							letras = letras + "<br><br>";
						}
					}
					var botones = document.getElementById("botones");
					botones.innerHTML = letras
							+ "<input alt='Borrar' type='Button' value='Borrar' onClick=anadir('<<','josso_password')><br><input type='Button' value='Espacio' onclick=anadir('&#160','josso_password')><input alt='Limpiar' type='Button' value='Limpiar' onClick=anadir('!!','josso_password')><br></br><input type='checkbox' name='mayusculas' onclick='cambiomayus(this)' checked>Mayusculas";
				</script>
				<a id="pregunta" href="javascript:mostrar()">Mostrar teclado</a><br />
			</div>
		</html:form>
	</div>
	<div class="password">Recuerde que su Contraseña a los Sistemas
		es personal y nadie puede solicitarle o exigirle por ningún medio que
		la divulgue.</div>
	<div class="mensaje">Para cualquier consulta Atención de Usuarios
		a los Internos 2576 - 2577 - 2585</div>
	<script type="JavaScript">
		anadir('!!','josso_password');
	</script>
</body>
</html>