<%@ page language="java" errorPage="/Error.jsp" import="rpba.PrintStackTrace"%>
<%@ page 
	import="java.sql.Connection,java.sql.DriverManager,java.sql.PreparedStatement,java.sql.*"%>
<%
	Connection conn = null;
	try {
		String scrip=(String)request.getAttribute("Host")+"/script/comun/arbol.js";
%>
<html>
<head>
<title>Limpiar base</title>
<script type='text/javascript' src='<%=scrip %>'></script>
	
</head>
<body>
<%
	java.util.Properties properties = new java.util.Properties();
	properties.setProperty("apli", "apli");
	java.lang.String URL = admApli.Configuracion.getString("admApli.path");
	conn = DriverManager.getConnection(URL, properties);
	String tablaBorrar = "";
	String nombreTablas = "%"; // Listamos todas las tablas
	String tipos[] = new String[1]; // Listamos sólo tablas
	tipos[0] = "TABLE";
	DatabaseMetaData dbmd = conn.getMetaData();
%>
<form action="./LimpiarBase.jsp">
<%
	if (request.getParameter("id") != null) {
		String[] tablas = request.getParameterValues("tabla");
		java.util.ArrayList<String> id = new java.util.ArrayList<String>();
		for (int i = 0; i < tablas.length; i++) {
			String[] aux = tablas[i].split(",");
			tablas[i] = aux[0];
			if (aux.length == 1) {
				id.add("id");
			} else {
				id.add(aux[1]);
			}
		}
		String sql;
		java.util.Hashtable<Integer,String> hash = new java.util.Hashtable<Integer,String>();
		String operacion="<";
		switch ( new Integer(request.getParameter("operacion")).intValue()){
			case 1:
				operacion=" <" ;
				break;
			case 2:
				operacion=" > ";
				break;
			case 3:
				operacion=" = ";
				break;
		}
		for (int i = 0; i < tablas.length; i++) {
			sql = "delete " + tablas[i];
			if (request.getParameter("id") != null) {
				sql = sql.concat(" where " + id.get(i) + operacion + request.getParameter("id"));
			}
			hash.put(new Integer(request.getParameter("orden"+ tablas[i])), sql);
		}
		PreparedStatement pre;
		for (int i = 0; i < tablas.length - 1; i++) {
			try {
				sql = hash.get(new Integer(i + 1)).toString();
				pre = conn.prepareStatement(sql);
				out.println(sql + " afecto:" + pre.executeUpdate()
						+ " registros <br>");
				pre.close();
			} catch (Exception e) {
				PrintStackTrace.printStackTrace("No se pudo limpiar la tabla "
						+ tablas[i] + ".<br>El sql es:"
						+ hash.get(new Integer(i))
						+ ".<br> El error fue: " + e.getMessage());
				PrintStackTrace.printStackTrace(e);
			}
		}
		try {
			sql = hash.get(new Integer(9999)).toString();
			pre = conn.prepareStatement(sql);
			out.println(sql + " afecto: " + pre.executeUpdate()
					+ " registros <br>");
			pre.close();
		} catch (Exception e) {
			PrintStackTrace.printStackTrace("No se pudo limpiar la tabla "
					+ tablas[tablas.length - 1]
					+ ".<br>El error fue: " + e.getMessage());
		}
		out.println("<br><a href='./LimpiarBase.jsp'>Volver</a>");
	} else {
		if (request.getParameter("tablaBorrar") == null) {
			ResultSet tablas = dbmd.getTables(null, null,nombreTablas, tipos);
			out.println("Seleccione la tabla desea borrar:<br>");
			while (tablas.next()) {
				out.println(tablas.getString(tablas
					.findColumn("TABLE_NAME"))
					+ "<input type='radio' id='borra' name='tablaBorrar' value='"
					+ tablas.getString(tablas.findColumn("TABLE_SCHEM"))
					+ "."
					+ tablas.getString(tablas.findColumn("TABLE_NAME"))
					+ "'></br>");
			}
			tablas.close();
		} else {
			tablaBorrar = request.getParameter("tablaBorrar").toUpperCase();
			String nombreTablaBorrar = tablaBorrar;
			tablaBorrar = tablaBorrar.substring(tablaBorrar.indexOf(".") + 1);
			out.println("Nota: el orden comienza en 1<br>");
			out.println("<h2>Las tablas que parecen estar relacionadas con <b>"	+ nombreTablaBorrar + "</b> son:</h2><br>");
			StringBuffer salida2 = new StringBuffer(
				"<h2>Las siguientes tablas parecen no estar relacionadas</h2> <br>");
			if (tablaBorrar.endsWith("ES")) {
				tablaBorrar = tablaBorrar.substring(0, tablaBorrar.length() - 2);
			}
			if (tablaBorrar.endsWith("S")) {
				tablaBorrar = tablaBorrar.substring(0, tablaBorrar.length() - 1);
			}
			ResultSet tablas = dbmd.getTables(null, null,nombreTablas, tipos);
			java.lang.String tabla;
			ResultSet result = null;
			while (tablas.next()) {
				tabla = tablas.getString(tablas.findColumn("TABLE_NAME"));
				String schema = tablas.getString(tablas.findColumn("TABLE_SCHEM"));
				ResultSet resultTa = dbmd.getTables(null, schema,tabla, tipos);
				tabla = tablas.getString(tablas.findColumn("TABLE_SCHEM"))+ "." + tabla;
				if (!nombreTablaBorrar.equals(tabla)) {
					while (resultTa.next()) {
						String tablaN = resultTa.getString("TABLE_NAME");
						result = dbmd.getColumns(null, schema, tablaN,"%");
						boolean ok = false;
						StringBuffer salida = new StringBuffer("<b>"+ tabla+ "</b> Orden <input type='text' name='orden"+ tabla + "' size='2'> <br>");
						while (result.next()) {
							salida.append(result.getString("COLUMN_NAME")+ "<input type='checkbox' id='"+tabla+"' name='tabla'value='"+ tabla+ ","+ result.getString("COLUMN_NAME")+ "'");
							if (result.getString("COLUMN_NAME").indexOf(tablaBorrar) != -1) {
								salida.append("checked='checked'");
								ok = true;
							}
							 salida.append(">");										 
						}
						salida.append("<br>");
						if (ok) {
							out.println(salida);
						} else {
							salida2.append(salida);
						}
						result.close();
					}
				}
				resultTa.close();
			}
			out.println(salida2);
			out.println("<br><br>Borrar los Id<br>");
			out.println("Menor <input type='radio' value='1' name='operacion'>");
			out.println("Mayor <input type='radio' value='2' name='operacion'>");
			out.println("Igual <input type='radio' value='3' name='operacion'>");
			out.println("que: <br><input type='text' name='id' value='1'size='4'><br>");
			out.println("<input type='hidden' name='tabla' value='"+ nombreTablaBorrar+ "'> <input type='hidden' name='orden"+ nombreTablaBorrar + "' value='9999'>");
		}
		out.println("<input type='submit'>");
	}
%>
</form>
</body>
</html>
<%} catch (Exception e) {
	out.println("murio" +e.getMessage()+ e.getCause());
	} finally {
		conn.close();
	}
%>