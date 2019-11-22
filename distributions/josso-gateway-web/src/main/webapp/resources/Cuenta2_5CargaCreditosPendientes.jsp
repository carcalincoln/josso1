<%@page import="admApli.modelo.Cuit"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="admApli.exceptions.RpbaInexistenteException"%>
<%@page import="admApli.BeanComparator"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Collection"%>
<%@page import="admApli.modelo.Persona"%>
<%@page import="admApli.dao.AdministradorOrganismo"%>
<%@page import="admApli.modelo.OrganismoProfesional"%>
<%@page import="cuenta.dao.AdministradorCredito"%>
<%@page import="java.util.Properties"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.math.BigInteger"%>
<%@page import="rpba.PrintStackTrace"%>
<%@page import="admApli.exceptions.RpbaException"%>
<%@page import="numOp.modelo.NumOp"%>
<%@page import="numOp.dao.AdministradorOperaciones"%>
<%@page import="cuenta.dao.AdministradorTipoOperacion"%>
<%@page import="cuenta.dao.AdministradorOperacion"%>
<%@page import="cuenta.dao.AdministradorTimbrado"%>
<%@page import="cuenta.modelo.Acreditacion"%>
<%@page import="cuenta.modelo.ValorAdicional"%>
<%@page import="cuenta.dao.AdministradorValorTasa"%>
<%@page import="admApli.dao.AdministradorServicio"%>
<%@page import="cuenta.modelo.TipoCredito"%>
<%@page import="admApli.modelo.ConNumOp"%>
<%@page import="admApli.modelo.Servicio"%>
<%@page import="admApli.modelo.Usuario"%>
<%@page import="admApli.dao.AdministradorUsuario"%>
<%@page import="admApli.Constantes"%>
<%@page import="admApli.dao.AdministradorFactory"%>
<%@page import="cuenta.dao.AdministradorDeCuenta"%>
<%@page import="cuenta.modelo.Tasa"%>
<%@page import="java.util.Date"%>
<%@page import="cuenta.modelo.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Pasaje de modulos pendientes  a Saldo</title>
</head>
<body>
	<div>
		<%
		    AdministradorDeCuenta administradorDeCuenta = AdministradorFactory.get(AdministradorDeCuenta.Constante,
				    AdministradorDeCuenta.class);

		    AdministradorTipoOperacion administardorTipoOperacion = AdministradorFactory
				    .get(AdministradorTipoOperacion.Constante, AdministradorTipoOperacion.class);
		    AdministradorOperaciones administardorOperaciones = AdministradorFactory
				    .get(AdministradorOperaciones.Constante, AdministradorOperaciones.class);
		    AdministradorOrganismo administradorOrganismo = AdministradorFactory.get(AdministradorOrganismo.Constante,
				    AdministradorOrganismo.class);
		    AdministradorCredito administradorCredito = AdministradorFactory.get(AdministradorCredito.Constante,
				    AdministradorCredito.class);
		    TipoOperacion tipoOperacion = administardorTipoOperacion.get(AdministradorTipoOperacion.ID_COMPRA_MODULO);
		    Servicio servicio = AdministradorFactory.get(AdministradorServicio.Constante, AdministradorServicio.class).getServicio(405);

		    out.println("<br>");

		    Date hoy = new Date();
		    TipoCredito tipo = null;
		    java.util.Iterator<OrganismoProfesional> organismos = administradorOrganismo.getOrganismos(1).iterator();
		    while (organismos.hasNext()) {
				OrganismoProfesional organismo = organismos.next();
				List<Credito> creditos = administradorCredito.getCreditosLibres(organismo);
				Iterator<Credito> iter = creditos.iterator();
				cuenta.modelo.Cuenta cuenta;
				out.println("<br>Organismo:");
				out.println(organismo.getDescripcion());
				out.println(
					"<table class='formulario'><thead><th>Timbrado</th><th>item</th><th>TipoCredito</th><th>monto informado</th><th>Monto Acreditado</th><th>NumOP</th></thead>");
				while (iter.hasNext()) {
				    Credito credito = iter.next();
				    Usuario usu = credito.getUsuario();
				    try {
						cuenta = administradorDeCuenta.getCuenta(usu);
				    } catch (RpbaInexistenteException e) {
						//No existe cuenta por lo tanto la creo
						cuenta = new Cuenta();
						cuenta.setUsuario(usu);
						cuenta.setSaldo(new Float(0));
						cuenta.setFechaSaldo(hoy);
						cuenta.persisti();
				    }
				    out.println("<tr><td>" + credito.getTimbrado().getNro() + "</td><td>" + credito.getItem_nume()
					    + "</td><td>" + credito.getTipoCredito().getDescripcion() + "</td>");
				    out.println("<td>" + credito.getTotal() + "</td>");
				    NumOp numOp = null;
				    Acreditacion acreditacion = null;
				    try {
						acreditacion = new Acreditacion(usu, credito, cuenta, tipoOperacion);
						out.print("<td>" + acreditacion.getMovimiento().getMonto() + "</td>");
						acreditacion.getMovimiento().setTipoOperacion(tipoOperacion);
						numOp = administardorOperaciones.otorgarNumeroOperacion(servicio, usu);
						out.print("<td>" + numOp.getNroOperacion() + "</td></tr>");
						cuenta.acreditar(acreditacion, numOp);
				    } catch (Exception e) {
						tipo = credito.getTipoCredito();
						System.out.println("Tipo: " + tipo);
						System.out.println("NumOP: " + numOp.getNroOperacion());
						System.out.println("Acreditacion: " + acreditacion);
						System.out.println(tipo.getTasa().getValorVigente().getMinimo());
				    }
				}
				out.println("</table>");
		    }
		    out.println("<br>");
		%>
	</div>
</body>
</html>