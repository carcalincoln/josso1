<%@page import="java.sql.DriverManager"%>
<%@page import="org.apache.cxf.ws.addressing.policy.AddressingAssertionBuilder"%>
<%@page import="java.sql.Connection"%>
<%@page import="org.apache.commons.lang3.StringUtils"%>
<%@page import="org.apache.commons.lang3.math.NumberUtils"%>
<%@page import="rpba.PrintStackTrace"%>
<%@page import="cuenta.dao.AdministradorDeCuenta"%>
<%@ page language="java"
	import="admApli.*,admApli.modelo.*,admApli.modelo.perfil.*,admApli.dao.*,java.util.*,java.io.*"
%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="display" uri="http://displaytag.sf.net"%>
<%!
	String limpiarPerfil(Perfil perfil, Connection conn) {
	String limpiarPerfil = "delete from admapli.perfiles_servicio where id_perfil =" + perfil.getId();
	try (java.sql.Statement stmt = conn.createStatement()) {
	    if(stmt.executeUpdate(limpiarPerfil) >= 0){
			return null;
	    }
	} catch (java.sql.SQLException e) {
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "limpiarPerfil");
	    parametros.put("Perfil", perfil);
	    PrintStackTrace.printStackTrace(e, parametros);
	}
	return "fallo Limpiar Perfil <br>"+ limpiarPerfil;
    }

    String borrarPerfil(Perfil perfil, Connection conn) {
	String limpiarPerfil = "delete from admapli.perfiles where id=" + perfil.getId();
	try (java.sql.Statement stmt = conn.createStatement()) {
	    if (stmt.executeUpdate(limpiarPerfil) > 0){
			return null;
	    }
	    else{
			return "fallo Borrar Perfil";
	    }
	} catch (java.sql.SQLException e) {
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "borrarPerfil");
	    parametros.put("Perfil", perfil);
	    PrintStackTrace.printStackTrace(e, parametros);
		return "fallo Borrar Perfil";
	}
    }

    String borrarPersona(Persona persona, Connection conn) {
		return null;
    }

    String borrarUsuarioAdministardor(AdmOrganismo administrador, Connection conn) {
	String borrarAdministrador = "delete from admapli.adms_org where id_usuario=" + administrador.getId();
	try (java.sql.Statement stmt = conn.createStatement()) {
	    if (stmt.executeUpdate(borrarAdministrador) > 0){
		return null;
	    }
	    else{
		return "fallo borrarUsuarioAdministardor";
	    }
	} catch (java.sql.SQLException e) {
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "borrarUsuarioAdministardor");
	    parametros.put("Administrador", administrador);
	    PrintStackTrace.printStackTrace(e, parametros);
		return "fallo borrarUsuarioAdministardor";
	}
    }

    String borrarUsuario(Usuario usuario, Connection conn) {
	String borrarUsuario = "delete from admapli.usuarios where id=" + usuario.getId();
	try (java.sql.Statement stmt = conn.createStatement()) {
	    if( stmt.executeUpdate(borrarUsuario) > 0){
		return null;
	    }
	    else{
		return "fallo borrarUsuario";
	    }
	} catch (java.sql.SQLException e) {
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "borrarUsuario");
	    parametros.put("Usuario", usuario);
	    PrintStackTrace.printStackTrace(e, parametros);
		return "fallo borrarUsuario";
	}
    }

    String borrarAdministrador(AdmOrganismo administrador, Connection conn) {
	String result=null;
	if ((result=limpiarPerfil(administrador.getPerfil(), conn))==null) {
	    if ((result=borrarUsuarioAdministardor(administrador, conn))==null) {
			if ((result=borrarUsuario(administrador, conn))==null) {
			    if ((result=borrarPerfil(administrador.getPerfil(), conn))==null) {
					return null;
			    }
			}
	    }
	}
	return result;
    }

    String borrarOrganismo(OrganismoProfesional organismo, AdministradorOrganismo adm, Connection conn) {
	String borrarUsuario = "delete from admapli.organismo where id=" + organismo.getId();
	try (java.sql.Statement stmt = conn.createStatement()) {
	    if(stmt.executeUpdate(borrarUsuario) > 0){
		return null;
	    }
	    else{
		return "fallo borrarOrganismo";
	    }
	} catch (java.sql.SQLException e) {
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "borrarOrganismo");
	    parametros.put("Organismo", organismo);
	    PrintStackTrace.printStackTrace(e, parametros);
	    return "fallo borrarOrganismo";
	}
    }

    String borrarOrganismo(OrganismoProfesional organismo, AdministradorOrganismo adm,
	    List<AdmOrganismo> administradores) {
	Iterator<AdmOrganismo> ite = administradores.iterator();
	Properties properties=new Properties();
	properties.setProperty("apli", "apli");
	String URL = Configuracion.getString("admApli.path");
	try (Connection conn = DriverManager.getConnection(URL, properties);) {
	    conn.setAutoCommit(false);
	    //Borro administradores
	    String ok =null;
	    while (ite.hasNext() && ok==null) {
			ok = borrarAdministrador(ite.next(), conn);
	    }
	    if (ok==null) {
			if ((ok=borrarOrganismo(organismo, adm, conn))==null) {
			    if ((ok=limpiarPerfil(organismo.getPerfil(), conn))==null) {
				if ((ok=borrarPerfil(organismo.getPerfil(), conn))==null) {
				    conn.commit();
					adm.getOrganismos().remove(organismo.getId());
				    return null;
				}
			    }
			}
	    }
	    conn.rollback();
	    return "Fallo Borrar Organismo: "+ok;
	} catch (Exception e) {
	    e.printStackTrace();
	    Map<String, Object> parametros = new HashMap<String, Object>();
	    parametros.put("Metodo", "borrarOrganismo");
	    parametros.put("Organismo", organismo);
	    PrintStackTrace.printStackTrace(e, parametros);
	    return "fallo borrar Organismo";
	}
    }
%>
<%
Ambiente ambiente = (Ambiente) request.getAttribute(Constantes.ClaveAmbiente);
if (!new admApli.modelo.Intranet().controlar(ambiente)) {
    response.sendRedirect((String) request.getAttribute("Host") + admApli.Configuracion.getString("DEFAULT_CONTEXT")
    + "/signon/login.do");
}
AdministradorOrganismo admiOrg = AdministradorFactory.get(AdministradorOrganismo.Constante,
	AdministradorOrganismo.class);
AdministradorUsuario admiUsu = AdministradorFactory.get(AdministradorUsuario.Constante, AdministradorUsuario.class);
OrganismoProfesional organismo = null;
boolean conexionesAdministradores = false;
java.util.List<AdmOrganismo> administradores = null;
try {
    if (StringUtils.isNotBlank(request.getParameter("idOrganismo"))) {
		Integer idOrganismo = NumberUtils.createInteger(request.getParameter("idOrganismo"));
		organismo = admiOrg.getOrganismo(idOrganismo);
		if (organismo != null) {
		    request.setAttribute("perfil", organismo.getPerfil()); 
			request.setAttribute("esquema", organismo.getPerfil().getEsquema());
		    pageContext.setAttribute("resultado", organismo);
		    administradores = (List<AdmOrganismo>)(List<?>)admiUsu.getAdminsOrganismo("", "", 0, "", organismo);
		    pageContext.setAttribute("administradores", administradores);
		    java.util.Iterator<AdmOrganismo> iter = administradores.iterator();
		    while (iter.hasNext()) {
				Usuario adm = iter.next();
				java.util.List<Conexion> connn = admiUsu.getConexiones(adm);
				if (!connn.isEmpty()) {
				    conexionesAdministradores = true;
				}
		    }
		    //RPBA cambiar el 2 por una constante
		    pageContext.setAttribute("usuarios", admiUsu.getUsuarios("", "", 0, "", "", 2, organismo));
		    pageContext.setAttribute("potenciales", admiUsu.getPotenciales("", "", 0, "", "", organismo));
		    if (StringUtils.isNotBlank(request.getParameter("confirm"))) {
				//aca hay que borrar
				String aux;
				if ((aux=borrarOrganismo(organismo, admiOrg,administradores))==null){
				    pageContext.setAttribute("ResultadoBorrar","<span class='exito'>Organismo Borrado exitosamente</span>");
				}
				else{
				    pageContext.setAttribute("ResultadoBorrar",aux);
				}
		    }
		}
		pageContext.setAttribute("conexionesAdministradores", conexionesAdministradores);
    }
	pageContext.setAttribute("organismos", admiOrg.getCollection());
} catch (Exception e) {
    PrintStackTrace.printStackTrace("Organismo: " + request.getParameter("idOrganismo"));
    PrintStackTrace.printStackTrace(e);
}
%>
<html>
<head>
<meta name="volver" content="/RegPropNew/resources/" />
<title>Borrar Organismo</title>
</head>
<body>
	<div id="formulario">
		<div class="titulo">Borrar Organismo</div>
		<FORM action="" method="get">
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">Organismo</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario"><select name="idOrganismo">
							<option>Seleccione Organismo</option>
							<c:forEach items="${organismos}" var="org">
								<option value="${org.id}">${org.descripcion}</option>
							</c:forEach>
					</select></td>
				</tr>
			</table>
			<div id="botonera">
				<INPUT type="submit" value="Enviar">
			</div>
		</FORM>
		<logic:present parameter="idOrganismo">
		<div class="tituloSeccion">Datos del Organismo
		</div>
			<logic:empty name="resultado">
				<div class="txtAdvertencia">
					No existe organismo con ID 
					${idOrganismo}
				</div>
			</logic:empty>
			<logic:notEmpty name="resultado">
				<logic:notEmpty name="ResultadoBorrar" scope="page">
					${ResultadoBorrar }
				</logic:notEmpty>
				<logic:empty name="ResultadoBorrar">
					<logic:empty name="usuarios" scope="page">
						<logic:empty name="potenciales" scope="page">
							<c:if test="${conexionesAdministradores}">
								<span class='txtError'>No se puede borrar porque hay administradores activos</span>
							</c:if>
							<c:if test="${!conexionesAdministradores}">
								<form>
									<h2>Confirma que desea borrar el organismo <b>${resultado.descripcion}</b></h2>
									<input type="hidden" value="${resultado.id }" name="idOrganismo" />
									<input type="hidden" value="${resultado.id }" name="confirm">
									<div id="botonera">
										<INPUT type="submit" value="Borrar">
									</div>
								</form>
							</c:if>
						</logic:empty>
						<logic:notEmpty name="potenciales">
							<span class='txtError'>No se puede borrar tiene usuarios Potenciales asociados</span>
						</logic:notEmpty>
					</logic:empty>
					<logic:notEmpty name="usuarios">
						<span class='txtError'>No se puede borrar tiene usuarios Titulares asociados</span>
					</logic:notEmpty>
				</logic:empty>
				<table class="formulario">
					<tr>
						<td class="nombreFormulario">ID</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">${resultado.id }</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Descripcion</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">${resultado.descripcion }</td>
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

							<comun:perfiles atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil" />
					</td>
				</tr>
				<tr>
						<td class="nombreFormulario">Administradores</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario"><display:table
								name="pageScope.administradores" export="false"
								defaultorder="descending" id="admin"
							>
								<display:column title="Logon" property="logon" sortable="true" />
								<display:column title="Nombre" property="persona.nombre" />
								<display:column title="Apellido" property="persona.apellido" />
								<c:if test="${conexionesAdministradores}">
									<display:column title="Conexiones" >
										<%
											pageContext.setAttribute("conexiones",admiUsu.getConexiones((Usuario)admin));
										%>
										<display:table name="pageScope.conexiones" export="false" pagesize="10" defaultorder="descending">						
											<display:column title="Desde" property="inicio" format="{0,date,dd/MM/yy HH:mm:ss a}" sortable="true"/>
											<display:column title="Hasta" property="fin" format="{0,date,dd/MM/yy HH:mm:ss a}" />
											<display:column title="Ip" property="ip" />
										</display:table>
									</display:column>
								</c:if>
							</display:table></td>
					</tr>
					<tr>
						<td class="nombreFormulario">Titulares</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario"><display:table
								name="pageScope.usuarios" export="false" defaultorder="descending"
							>
								<display:column title="Logon" property="logon" sortable="true" />
								<display:column title="Nombre" property="persona.nombre" />
								<display:column title="Apellido" property="persona.apellido" />
							</display:table></td>
					</tr>
					<tr>
						<td class="nombreFormulario">Potenciales</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario"><display:table
								name="pageScope.potenciales" export="false"
								defaultorder="descending"
							>
								<display:column title="Logon" property="logon" sortable="true" />
								<display:column title="Nombre" property="persona.nombre" />
								<display:column title="Apellido" property="persona.apellido" />
							</display:table></td>
					</tr>
				</table>
				</logic:notEmpty>
		</logic:present>
	</div>
</body>
</html>