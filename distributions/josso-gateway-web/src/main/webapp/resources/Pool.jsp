<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.Constantes,admApli.modelo.dtos.Error,admApli.*"%>
<%@ page import="admApli.dao.AdministradorAmbiente"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)){
		response.sendRedirect((String)request.getAttribute("Host")+admApli.Configuracion.getString("DEFAULT_CONTEXT")+"/signon/login.do");
	}
	rpba.pool.sql.DriverConexion driver=((rpba.pool.sql.DriverConexion)java.sql.DriverManager.getDriver("jdbc:jreg:"));
	pageContext.setAttribute("pool",driver.getPool());
%>
<html>
<head>
	<title>Informacion del pool</title>
	<meta content="/RegPropNew/resources/usuarioHash.jsp"  name="volver"/>
</head>
<body>
	<logic:present parameter="limpiar">
	<%
		if (driver.getPool().limpiar()){
			out.println("<div class='exito'>Se limpio el pool con exito</div>");
		}
		else{
			out.println("<div class='txtError'>Ocurrio un error mire los logs</div>");
		}
	%>
	</logic:present>
	<logic:present parameter="control">
		<%
			driver.getPool().reapConnections();
			out.println("<div class='exito'>Se controlo el pool con exito</div>");
		%>
	</logic:present>
	<div id="formulario">
		<div class="titulo">Estado del pool</div>
		<bean:write name="pool" property="timeout"/>
		
		<logic:present parameter="configurar">
			<div>
				<form action="">
					Time Out: <input name="timeOut" /> <br></br>
					<input type="submit"/>
				</form>
			</div>
		</logic:present>
		<table class="listado">
			<thead>
				<tr>
					<th>Usuario</th>
					<th>Max</th>
					<th>Min</th>
					<th>Actual</th>
					<th>Desde</th>
				</tr>
			</thead>
			<tbody>
			<logic:iterate id="element" name="pool" property="apliConf" indexId="pos">
				<bean:define id="apliConf" name="element" property="value"/>
				<tr class='<%=pos%2==0?"even":"odd"%>'>
					<td><bean:write name="apliConf" property="idApli"/></td>
					<td><bean:write name="apliConf" property="maxCon"/></td>
					<td><bean:write name="apliConf" property="minCon"/></td>
					<td><bean:size name="apliConf" property="conexiones" id="size"/><bean:write name="size"/></td>
					<td>
						<logic:iterate id="conn" name="apliConf" property="conexiones" type="rpba.pool.sql.Conexion">
							<jsp:useBean id="fecha" class="java.util.GregorianCalendar" />
							<jsp:setProperty name="fecha"  property="timeInMillis" value="${conn.lastUse}"/>
							<bean:write name="fecha" property="time" format="hh:mm:ss a" />
							<%=conn.inUse() %>
							<br>
						</logic:iterate>
					</td>
				</tr>
			</logic:iterate>
			</tbody>
		</table>
		<html:link page="/resources/Pool.jsp">
			<html:param name="limpiar" value="1"/>
			Limpiar conexiones
		</html:link><br></br>
		<html:link page="/resources/Pool.jsp">
			<html:param name="control" value="1"/>
			Controlar conexiones
		</html:link><br></br>		
	</div>
</body>
</html>