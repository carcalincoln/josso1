<%@page import="org.apache.commons.lang3.math.NumberUtils"%>
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
		String userName=request.getParameter("logon").trim();
		if (NumberUtils.isCreatable(userName)){
			PrintStackTrace.printStackTrace("Busco por ID");
			Integer logoId=NumberUtils.createInteger(userName);			
			usuario=administardorUsuario.getUsuario(logoId,false);
		}
		else{
			usuario = administardorUsuario.getUsuario(userName);
		}
		pageContext.setAttribute("resultado", usuario);
		ArrayList<Conexion> con=administardorUsuario.getConexiones(usuario);
		BeanComparator.Sort(con, Conexion.class, "inicio",false);
		pageContext.setAttribute("conexiones", con);
		if (usuario.isInterno()) {
			HashMap<?, ?> esquemaPerfil = usuario.esquemaDePosiblePerfil();
			request.setAttribute("esquema", esquemaPerfil);
		} else {
			request.setAttribute("esquema", usuario.getPerfil().getEsquema());
		}
		request.setAttribute("perfil", usuario.getPerfil());
		cuenta.modelo.Cuenta cuenta=null;
		if (!usuario.getTipoUsuario().isExcento()){
			AdministradorDeCuenta administardorDeCuenta= AdministradorFactory.get(AdministradorDeCuenta.Constante,AdministradorDeCuenta.class);
			if(!usuario.isAdmOrganismo()){
		    	cuenta =administardorDeCuenta.getCuenta(usuario);
			}
			pageContext.setAttribute("cuenta", cuenta);
		}
	} catch (Exception e) {
		PrintStackTrace.printStackTrace("Logon: " + request.getParameter("logon"));
		PrintStackTrace.printStackTrace(e);
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
					<td class="nombreFormulario">Logon/ID</td>
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
					No existe usuario con logon/id:
					<bean:write name="logon" />
				</div>
			</logic:notEmpty>
		</logic:empty>
		<logic:notEmpty name="resultado">
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">ID</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.id }</td>
				</tr>			
				<tr>
					<td class="nombreFormulario">Logon</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.logon }</td>
				</tr>
				<tr>
					<td class="nombreFormulario">Tipo Usuario</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.getClass().getSimpleName()}</td>
				</tr>				
				<logic:equal value="true" name="resultado" property="autorizado">
					<tr>
						<td class="nombreFormulario">Titular</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							<a href="?logon=${resultado.getTitular().getId()}">${resultado.getTitular().persona.apellido},&nbsp;${resultado.getTitular().persona.nombre}</a>
						</td>
					</tr>
				</logic:equal>
				<logic:equal value="true" name="resultado" property="interno">
					<tr>
						<td class="nombreFormulario">${resultado.estructura.tipoOficina.nombre}</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">${resultado.estructura.nombre}</td>
					</tr>
				</logic:equal>
				<logic:equal value="true" name="resultado" property="titular">
					<tr>
						<td class="nombreFormulario">Organismo</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">${resultado.organismoProfesional}</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Autorizados</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							<logic:present parameter="autorizados">
								<display:table name="resultado.autorizados" export="false" defaultorder="descending">						
									<display:column title="Logon" property="logon" sortable="true" href="BuscarUsuario.jsp" paramId="logon" paramProperty="logon"/>
									<display:column title="Nombre" property="persona.nombre" />
									<display:column title="Apellido" property="persona.apellido" />
								</display:table>
							</logic:present>	
							<logic:notPresent parameter="autorizados">
								<a href="?autorizados=1&logon=${resultado.id}">Ver Autorizados</a>
							</logic:notPresent>						
						</td>
					</tr>					
				</logic:equal>				
				<logic:equal value="true" name="resultado" property="admOrganismo">
					<tr>
						<td class="nombreFormulario">Organismo</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">${resultado.organismo}</td>
					</tr>
				</logic:equal>
				<tr>
					<td class="nombreFormulario">Id_Persona</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.id}</td>
				</tr>				
				<tr>
					<td class="nombreFormulario">Nombre</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.nombre }</td>
				</tr>
				<tr>
					<td class="nombreFormulario">Apellido</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.apellido}</td>
				</tr>
				<tr>
					<td class="nombreFormulario">CUIT</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.cuit_cuil}</td>
				</tr>				
				<tr>
					<td class="nombreFormulario">Tipo Documento</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.tipoDocumento}</td>
				</tr>
				<tr>
					<td class="nombreFormulario">Documento</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.persona.documento}</td>
				</tr>
				<tr>
					<td class="nombreFormulario">Estado</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.estadoUsuario}</td>
				</tr>
				<logic:present name="cuenta" scope="page">
					<tr>
						<td class="nombreFormulario">Saldo Cuenta($)</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario"><bean:write name="cuenta" property="saldo" format="###,##0.00" /></td>
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
					<td class="campoFormulario">
						<logic:equal value="true" name="resultado" property="interno">
							<comun:perfilesInterno atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil" />
						</logic:equal>
						<logic:notEqual value="true" name="resultado" property="interno">
							<comun:perfiles atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil" />
						</logic:notEqual>
					</td>
				</tr>
			</table>
		</logic:notEmpty>
	</div>
</body>
</html>