<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.sql.DatabaseMetaData"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@ page language="java" autoFlush="true" buffer="8kb"%>
<html>
<head>
<title>Prueba SQL Gateway</title>
	<meta content="identity" name="decorator"/> 
</head>
<body>
<div>
	<%
		String url="jdbc:connx:DD=produccion;Gateway=neptuno";
		Class.forName("com.Connx.jdbc.TCJdbc.TCJdbcDriver").newInstance();
		Connection conn = DriverManager.getConnection(url,"desa","desa");
		String tableNamePattern="%";
		String[] types = { "TABLE" };
		ResultSet tablas=null;
		tablas = conn.getMetaData().getTables(null, null, tableNamePattern,types);
		out.println("<table border='1'><tr><th>Table_name</th><th>table_schem</th><th>Datos</th><th>Columnas</th></tr>");
		while (tablas.next()) {
		    String owner=tablas.getString("TABLE_SCHEM");
		    String nombre=tablas.getString("TABLE_NAME");
			out.println("<tr><td> "+nombre + "</td><td>"+owner+"</td><td><a href='PruebasqlGatewayTabla.jsp?tabla="+owner+"."+nombre+"'>ver Datos</a></td><td><ul>");
			ResultSet res = conn.getMetaData().getColumns(null, owner, nombre,"%");
			while (res.next()) {
				out.println("<li>"+res.getString("COLUMN_NAME")+"<ul>");
				out.println("<li>DATA_TYPE: "+res.getInt("DATA_TYPE")+"</li>");
				out.println("<li>TYPE_NAME: "+res.getString("TYPE_NAME")+"</li>");
				out.println("<li>COLUMN_SIZE: "+res.getInt("COLUMN_SIZE")+"</li>");
				out.println("<li>IS_NULLABLE: "+res.getString("IS_NULLABLE")+"</li>");
				out.println("<li>COLUMN_DEF: "+res.getString("COLUMN_DEF")+"</li>");
				out.println("</ul></li>");
			}
			out.println("</ul><td></tr>");
		}
		out.println("</table>");
		conn.close();
	%>
	</div>
</body>
</html>