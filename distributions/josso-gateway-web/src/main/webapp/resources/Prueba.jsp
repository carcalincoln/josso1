<%@page import="rpba.IPUtils"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Enumeration"%>
<%@page import="admApli.exceptions.RpbaGeneralException"%>
<%@page import="admApli.dao.AdministradorAmbiente"%>
<%@page import="admApli.dao.AdministradorFactory"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.dtos.Error,admApli.*"%>
<%@ page import="admApli.modelo.OrganismoProfesional"%>
<%@ page import="admApli.dao.AdministradorUsuario"%>
<%@ page import="admApli.dao.AdministradorUsuario.DtoHash"%>
<%@ page import="admApli.dao.AdministradorOrganismo"%>
 
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<html>
<head>
<title>Información de IP</title>
</head>
<body>
	<%
	
		java.util.GregorianCalendar aux2 = new java.util.GregorianCalendar(0,0,0);
		out.println(aux2);
		out.println("Proxy_host:    "+ request.getParameter("proxy_host")+"<br><br><br>");
		out.println("host:    "+ request.getHeader("host")+"<br>");
		out.println("<br>getClientIPAddress : "+ IPUtils.getClientIPAddress(request)+"<br>");
		out.println("IP Publica "+IPUtils.findNonPrivateIpAddress(IPUtils.getClientIPAddress(request)));
		out.println("<br> Ambiente: "+AdministradorAmbiente.getInstance().getAmbiente(IPUtils.getClientIPAddress(request)).getDescripcion());
		out.println("<br> Ambiente request "+request.getAttribute(Constantes.ClaveAmbiente));
		out.println("<br> IP request "+request.getAttribute(Constantes.ClaveIp));
		java.util.Enumeration<String> aux=(Enumeration<String>)request.getParameterNames();
		out.println("param");
		String clave;
		while(aux.hasMoreElements()){
			clave=aux.nextElement();
			out.println(clave+":  "+ request.getParameter(clave)+"<br>");
		}
		out.println("attribute");
		aux=(Enumeration<String> )request.getAttributeNames();
		while(aux.hasMoreElements()){
			clave=aux.nextElement();
			out.println(clave+":  "+ request.getAttribute(clave)+"<br>");
		}
		
		out.println("header");
		aux=(Enumeration<String> )request.getHeaderNames();
		while(aux.hasMoreElements()){
			clave=aux.nextElement();
			out.println(clave+":  "+ request.getHeader(clave)+"<br>");
		}
		
		
	 	Cookie[] cookies = request.getCookies();
        boolean foundCookie = false;

        for(int i = 0; i < cookies.length; i++) { 
            Cookie c = cookies[i];
            out.println("path= " + c.getPath()+" <br>");
            out.println("comment= " + c.getComment()+" <br>");
            out.println("name= " + c.getName()+" <br>");
            out.println("domain= " + c.getDomain()+" <br>");
            out.println("value = " + c.getValue()+" <br>");
            out.println("secure = " + c.getSecure()+" <br>");
        
        }
        
        rpba.pool.sql.DriverConexion driver=((rpba.pool.sql.DriverConexion)java.sql.DriverManager.getDriver("jdbc:jreg:"));
		pageContext.setAttribute("pool",driver.getPool());
		Connection connApli=driver.getPool().getConexion("apli2");
       
        
        PreparedStatement pre = connApli.prepareStatement("select * from admapli.bloque"); 
        ResultSet resultSet= pre.executeQuery(); 
        while (resultSet.next()){
            System.out.print(resultSet.getTime("horainicio"));
        }
        resultSet.close();
        pre.close();
        connApli.close();
	%>
</body>
</html>