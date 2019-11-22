<%@page import="admApli.modelo.TipoRegistracion"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="admApli.modelo.TipoTramite"%>
<%@page import="admApli.fechas.ProcesadorDeFechas"%>
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
<title>Insert title here</title>
<meta name="decorator" content="identity">
</head>
<body>
	<%
	Properties properties= new Properties();
	properties.put("apli", "cuenta2");
	java.sql.Connection conn=DriverManager.getConnection("jdbc:jreg://",properties);
	String sql="select * from cuenta2adm.valores_tasa order by id_tasa,desde";
	ResultSet resultSet= conn.createStatement().executeQuery(sql);
	ValorTasa anterior= null;
	TipoRegistracion tipoRegistracion = TipoRegistracion.Matricula;
	TipoTramite tipoTramite = TipoTramite.Urgente;
	ArrayList<ValorTasa> valores=  new ArrayList<ValorTasa>();  
	while(resultSet.next()){
	    ValorTasa valor= new ValorTasa();
	    Tasa tasa= new Tasa(resultSet.getInt("id_tasa"),"");
	    valor.setTasa(tasa);
	    valor.setFechaDesde(resultSet.getDate("desde"));
	    valor.setFechaHasta(null);
	    if(anterior!=null){
			if (anterior.getTasa().getId()==valor.getTasa().getId()){
			    Date aux=ProcesadorDeFechas.restarDias(valor.getFechaDesde(), 1);
			    anterior.setFechaHasta(aux);
			}
			else{
			    anterior=null;
			}
	    }
	    valor.setResolucion(resultSet.getString("resolucion"));
	    valor.setMinimo(resultSet.getFloat("monto"));	    
	    valor.setTipoRegistracion(tipoRegistracion);
	    valor.setTipoTramite(tipoTramite);
	    Integer id_usuario=resultSet.getInt("id_usuario");
	    if(resultSet.wasNull()){
			//Seteo usuario por defecto a los que no tienen
			id_usuario=374;//3425
	    }
	    valor.setIdUsuario(id_usuario);
	    valor.setAuFecha(resultSet.getDate("aufecha"));
	    ArrayList<ValorAdicional> valoresAdicionales= new ArrayList<ValorAdicional>();
	    ValorAdicional aux= new ValorAdicional();
	    
	    aux.setAUFecha(valor.getAuFecha());
	    aux.setDesde(valor.getFechaDesde());
	    aux.setHasta(valor.getFechaHasta());
	    aux.setId_usuario(valor.getIdUsuario());
	    aux.setMinimo(valor.getMinimo());
	    aux.setProducto(new Float(1));
	    aux.setPorModulo(true);
	    aux.setValor(aux.getMinimo());
	    aux.setValorTasa(valor);
	    valoresAdicionales.add(aux);
	    valor.setValorAdicional(valoresAdicionales);
	    valores.add(valor);
	    anterior=valor;
	}
	conn.close();
	Iterator<ValorTasa> iter=valores.iterator();
	AdministradorValorTasa administrador= AdministradorFactory.get(AdministradorValorTasa.Constante,AdministradorValorTasa.class);
	while(iter.hasNext()){
	    ValorTasa vt= iter.next();
	    administrador.persisti(vt);
	    out.println("id_tasa: "+vt.getTasa().getId()+" desde: "+vt.getFechaDesde()+" hasta: "+ vt.getFechaHasta()+"<br>");
	    if(vt.getFechaHasta()==null){
			out.println(" <br><br>");
	    }
	}
	%>
</body>
</html>