<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<html>
	<head>
		<title><decorator:title  />::RPBA</title>
		<decorator:head />
		<link rel="stylesheet" type="text/css" media="print" href="<%=admApli.Path.getRecurso()%>/style/comun/styleServiciosWeb2011Print.css"/>
	</head>
	<body>
		<h1><decorator:title /></h1>
		<decorator:body />
	</body>
</html>