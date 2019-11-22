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
<title>Migracion de modulos libres a Saldo</title>
</head>
<body>
	<div>
		<%
		    AdministradorDeCuenta administradorDeCuenta = AdministradorFactory.get(AdministradorDeCuenta.Constante, AdministradorDeCuenta.class);

		    AdministradorTipoOperacion administardorTipoOperacion = AdministradorFactory.get(AdministradorTipoOperacion.Constante, AdministradorTipoOperacion.class);
		    AdministradorOperaciones administardorOperaciones = AdministradorFactory.get(AdministradorOperaciones.Constante, AdministradorOperaciones.class);

		    AdministradorCredito administradorCredito = AdministradorFactory.get(AdministradorCredito.Constante, AdministradorCredito.class);
		    AdministradorUsuario administradorUsuario = AdministradorFactory.get(AdministradorUsuario.Constante,  AdministradorUsuario.class);
		    AdministradorOrganismo administradorOrganismo = AdministradorFactory.get(AdministradorOrganismo.Constante, AdministradorOrganismo.class);
		    Servicio servicio = AdministradorFactory.get(AdministradorServicio.Constante, AdministradorServicio.class).getServicio(404);
			TipoOperacion tipoOperacion=administardorTipoOperacion.get(AdministradorTipoOperacion.ID_ACREDITACION_MODULO);
		    out.println("<br>");
		    
		    List<TipoCredito> aux222= new ArrayList<TipoCredito>(administradorDeCuenta.getTiposCredito().values());
		    BeanComparator.Sort(aux222,TipoCredito.class,"descripcion");
		    java.util.Iterator<TipoCredito> iter = aux222.iterator();
		    Date hoy = new Date();
		    TipoCredito tipo = null;
		    try {
				out.println("<table><thead><th>tipo</th><th>monto</th></thead>");
				while (iter.hasNext()) {
				    tipo = iter.next();
				    out.println("<tr><td>" + tipo.getDescripcion() + "</td><td>" + tipo.getMonto() + "</td><tr>");
				}
				out.println("</table>");

				java.util.Iterator<OrganismoProfesional> organismos = administradorOrganismo.getOrganismos(1).iterator();
				while (organismos.hasNext()) {
				    OrganismoProfesional organismo = organismos.next();
					out.println("<br><b>Organismo</b>:" + organismo.getDescripcion() + "<br><br>");
					java.util.Iterator<Usuario> titulares = administradorUsuario.getTitulares(null, null, 0, null, null, organismo).iterator();
					cuenta.modelo.Cuenta cuenta;
					while (titulares.hasNext()) {
					    Usuario usu = titulares.next();
					    try {
						cuenta = administradorDeCuenta.getCuenta(usu);
					    } catch (RpbaInexistenteException e) {
							cuenta = new Cuenta();
							cuenta.setUsuario(usu);
							cuenta.setSaldo(new Float(0));
							cuenta.setFechaSaldo(hoy);
							cuenta.persisti();
					    }

					    Persona persona = usu.getPersona();
					    out.println("usuario: " + persona.getApellido() + " - " + persona.getNombre() + " - " + persona.getCuit_cuil());

					    java.util.Iterator<Credito> creditos = administradorCredito.getCreditosLibres(usu).iterator();
						Double total = new Double(0);
					    if (creditos.hasNext()) {
							out.println("<table class='formulario'><thead><th>Timbrado</th><th>item</th><th>TipoCredito</th><th>monto informado</th><th>Monto Acreditado</th><th>saldo</th></thead>");
							while (creditos.hasNext()) {
							    Credito credito = creditos.next();
							    out.println("<tr><td>" + credito.getTimbrado().getNro() + "</td><td>" + credito.getItem_nume() + "</td><td>" + credito.getTipoCredito().getDescripcion() + "</td>");
							    out.println("<td>" + credito.getTotal() + "</td>");
							    NumOp numOp=null;
							    Acreditacion acreditacion=null;
							    try {
									float monto = credito.getTipoCredito().getMonto();
									out.print("<td>" + monto + "</td>");
									total = total + monto;
									out.println("<td>" + total + "</td></tr>");
									acreditacion = new Acreditacion(usu, credito, cuenta, tipoOperacion);
									numOp = administardorOperaciones.otorgarNumeroOperacion(servicio, usu);
								    cuenta.acreditar(acreditacion, numOp);
							    }catch (Exception e) {
									tipo = credito.getTipoCredito();
									System.out.println("Tipo: "+tipo);
									System.out.println("NumOP: "+numOp.getNroOperacion());
									System.out.println("Acreditacion: "+acreditacion);
									System.out.println(tipo.getTasa().getValorVigente().getMinimo());
							    }
							}
							out.println("</table>");
					    } else {
							out.println("<b>No tienen modulos Libres</b>");
					    }
					    out.println("<br>total: "+total + " saldo cuenta: "+cuenta.getSaldo());
					    out.println("<br>");
					}
				}
		    } catch (Exception e) {
				System.out.println(tipo.getTasa());
				Iterator<ValorTasa> vt1 = tipo.getTasa().getValoresTasa().iterator();
				while (vt1.hasNext()) {
				    ValorTasa aux3 = vt1.next();
				    System.out.println("Minimo: " + aux3.getMinimo() + " Monto: " + aux3.getMonto() + " desde: " + aux3.getFechaDesde() + " hasta: " + aux3.getFechaHasta() + " Vigente: " + aux3.vigente(hoy));
				}
				System.out.println("Vigente: " + tipo.getTasa().getValorVigente());
				PrintStackTrace.printStackTrace(e);
				out.print(PrintStackTrace.getStackTrace(e, true));
		    }
		    out.println("<br>");
		%>
	</div>
</body>
</html>