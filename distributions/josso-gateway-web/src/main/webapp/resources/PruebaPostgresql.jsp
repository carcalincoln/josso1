
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java"%>
<html>
<head>
<title>Prueba Postgre</title>
</head>
<body>
	<%
		String url="jdbc:connx:DD=produccion;Gateway=neptuno";
		Class.forName("com.Connx.jdbc.TCJdbc.TCJdbcDriver").newInstance();
		Connection conn = DriverManager.getConnection(url,"desa","desa");
	    String tabla = request.getParameter("tabla");
	    String limite = request.getParameter("limite");
	    PreparedStatement pre = conn.prepareStatement("select * from " + tabla + " limit "+limite);
	    ResultSet res = pre.executeQuery();
	    java.sql.ResultSetMetaData metaData = res.getMetaData();
	    int count = metaData.getColumnCount();
	    String columnName[] = new String[count];
	    out.println("<table class='listado'><tr>");
	    for (int i = 1; i <= count; i++) {
			columnName[i - 1] = metaData.getColumnLabel(i);
			out.println("<th>" + columnName[i - 1] + "</th>");
	    }
	    out.println("</tr>");
	    long inicio = System.currentTimeMillis();
	    while (res.next()) {
			out.println("<tr>");
			for (int i = 1; i <= count; i++) {
			    out.println("<td>" + res.getString(columnName[i - 1]) + "</td>");
			}
			out.println("</tr>");
	    }
	    long fin = System.currentTimeMillis();
	    out.println("</table><br>Tiempo(milisegundos) : " + (fin - inicio));
	    System.out.println("tiempo: " + (fin - inicio));
	    conn.close();
	%>
</body>
</html>