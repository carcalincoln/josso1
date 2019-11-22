<%@page import="rpba.PrintStackTrace"%>
<%@page import="cuenta.dao.AdministradorDeCuenta"%>
<%@ page language="java"  import="admApli.*,admApli.modelo.*,admApli.modelo.perfil.*,admApli.dao.*,java.util.*,java.io.*"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib prefix="display" uri="http://displaytag.sf.net"%>
<%
    Ambiente ambiente = (Ambiente) request.getAttribute(Constantes.ClaveAmbiente);
    if (!new admApli.modelo.Intranet().controlar(ambiente)) {
		response.sendRedirect((String) request.getAttribute("Host")
			+ admApli.Configuracion.getString("DEFAULT_CONTEXT") + "/signon/login.do");
    }
    AdministradorUsuario administardorUsuario = AdministradorFactory.get(AdministradorUsuario.Constante,
		    AdministradorUsuario.class);
    admApli.modelo.Usuario usuario = null;
%>
<bean:parameter name="logon" id="logon" value="" />
<logic:notEmpty name="logon">
	<%
	try {
		usuario = administardorUsuario.getUsuario(request.getParameter("logon"));
		pageContext.setAttribute("resultado", usuario);
		if (usuario.isInterno()) {
			HashMap<?, ?> esquemaPerfil = usuario.esquemaDePosiblePerfil();
			request.setAttribute("esquema", esquemaPerfil);
		} else {
			request.setAttribute("esquema", usuario.getPerfil().getEsquema());
		}
		request.setAttribute("perfil", usuario.getPerfil());
	} catch (Exception e) {
		PrintStackTrace.printStackTrace("Logon: " + request.getParameter("logon"));
		PrintStackTrace.printStackTrace(e);
	}
	ArrayList<Conexion> con= administardorUsuario.getConexiones(usuario);
	BeanComparator.Sort(con, Conexion.class, "inicio",false);
	pageContext.setAttribute("conexiones", con);
	cuenta.modelo.Cuenta cuenta=null;
	if (!usuario.getTipoUsuario().isExcento()){
		AdministradorDeCuenta administardorDeCuenta= AdministradorFactory.get(AdministradorDeCuenta.Constante,AdministradorDeCuenta.class);
		if(!usuario.isAdmOrganismo()){
		    cuenta =administardorDeCuenta.getCuenta(usuario);
		}
		/*else{
		    cuenta =administardorDeCuenta.getCuenta(usuario.getOrganismo());
		}*/
		pageContext.setAttribute("cuenta", cuenta);
	}
	%>
</logic:notEmpty>
<html>
<head>
<meta name="volver" content="/RegPropNew/resources/" />
<title>Datos de usuario</title>
</head>
<body>
	<div id="formulario">
		<div class="titulo">Datos del usuario</div>
		<FORM action="/RegPropNew/resources/BuscarUsuario.jsp" method="get">
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">Logon</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><INPUT type="text" name="logon" maxlength="15" /></td>
				</tr>
			</table>
			<div id="botonera">
				<INPUT type="submit" value="Enviar">
			</div>
		</FORM>
		<logic:empty name="resultado">
			<logic:notEmpty name="logon">
				<div class="txtAdvertencia">
					No existe usuario con logon:
					<bean:write name="logon" />
				</div>
			</logic:notEmpty>
		</logic:empty>
		<logic:notEmpty name="resultado">
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">Logon</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="logon" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Nombre</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="persona.nombre" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Apellido</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="persona.apellido" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">CUIT</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="persona.cuit_cuil" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Tipo Documento</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="persona.tipoDocumento" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Documento</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="persona.documento" /></td>
				</tr>
				<tr>
					<td class="nombreFormulario">Estado</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><bean:write name="resultado" property="estadoUsuario" /></td>
				</tr>
				<logic:present name="resultado" property="cuenta">
					<tr>
						<td class="nombreFormulario">Saldo Cuenta($)</td>
						<td class="separadorCampoFormulario">:</td>
						
						<td class="campoFormulario"><bean:write name="cuenta" property="saldo" format="###,##0.00" /></td>
					</tr>
				</logic:present>				
				<logic:present name="resultado" property="organismo">
					<tr>
						<td class="nombreFormulario">Organismo</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario"><bean:write name="resultado" property="organismo" /></td>
					</tr>
				</logic:present>
				<tr>
					<td class="nombreFormulario">Conexiones</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">
						<display:table name="pageScope.conexiones" export="false" pagesize="10" defaultorder="descending">						
							<display:column title="Desde" property="inicio" format="{0,date,dd/MM/yy HH:mm:ss a}" sortable="true"/>
							<display:column title="Hasta" property="fin" format="{0,date,dd/MM/yy HH:mm:ss a}" />
							<display:column title="Ip" property="ip" />
						</display:table>
					</td>
				</tr>
				<tr>
					<td class="nombreFormulario">Perfil</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"></td>
				</tr>
				<tr>
					<td class="nombreFormulario"></td>
					<td class="separadorCampoFormulario"></td>
					<td class="campoFormulario"><logic:equal value="true" name="resultado" property="interno">
							<comun:perfilesInterno atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil" />
						</logic:equal> <logic:notEqual value="true" name="resultado" property="interno">
							<comun:perfiles atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil" />
						</logic:notEqual></td>
				</tr>
			</table>
		</logic:notEmpty>
	</div>
</body>
</html>