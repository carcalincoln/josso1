<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.*, admApli.*, java.util.*,java.net.*,java.text.*,java.io.*"%>
<%!
	/**
	 * Copies all data from in to out
	 * 	@param in the input stream
	 *	@param out the output stream
	 *	@param buffer copy buffer
	 */
	static void copyStreamsWithoutClose(InputStream in, OutputStream out, byte[] buffer)
			throws IOException {
		int b;
		while ((b = in.read(buffer)) != -1)
			out.write(buffer, 0, b);
	}
	/**
	 * Returns the Mime Type of the file, depending on the extension of the filename
	 */
	static String getMimeType(String fName) {
		fName = fName.toLowerCase();
		if (fName.endsWith(".jpg") || fName.endsWith(".jpeg") || fName.endsWith(".jpe")) return "image/jpeg";
		else if (fName.endsWith(".gif")) return "image/gif";
		else if (fName.endsWith(".pdf")) return "application/pdf";
		else if (fName.endsWith(".htm") || fName.endsWith(".html") || fName.endsWith(".shtml")) return "text/html";
		else if (fName.endsWith(".avi")) return "video/x-msvideo";
		else if (fName.endsWith(".mov") || fName.endsWith(".qt")) return "video/quicktime";
		else if (fName.endsWith(".mpg") || fName.endsWith(".mpeg") || fName.endsWith(".mpe")) return "video/mpeg";
		else if (fName.endsWith(".zip")) return "application/zip";
		else if (fName.endsWith(".tiff") || fName.endsWith(".tif")) return "image/tiff";
		else if (fName.endsWith(".rtf")) return "application/rtf";
		else if (fName.endsWith(".mid") || fName.endsWith(".midi")) return "audio/x-midi";
		else if (fName.endsWith(".xl") || fName.endsWith(".xls") || fName.endsWith(".xlv")
				|| fName.endsWith(".xla") || fName.endsWith(".xlb") || fName.endsWith(".xlt")
				|| fName.endsWith(".xlm") || fName.endsWith(".xlk")) return "application/excel";
		else if (fName.endsWith(".doc") || fName.endsWith(".dot")) return "application/msword";
		else if (fName.endsWith(".png")) return "image/png";
		else if (fName.endsWith(".xml")) return "text/xml";
		else if (fName.endsWith(".svg")) return "image/svg+xml";
		else if (fName.endsWith(".mp3")) return "audio/mp3";
		else if (fName.endsWith(".ogg")) return "audio/ogg";
		else return "text/plain";
	}
	
	/**
	 * Wrapperclass to wrap an OutputStream around a Writer
	 */
	class Writer2Stream extends OutputStream {

		Writer out;

		Writer2Stream(Writer w) {
			super();
			out = w;
		}

		public void write(int i) throws IOException {
			out.write(i);
		}

		public void write(byte[] b) throws IOException {
			for (int i = 0; i < b.length; i++) {
				int n = b[i];
				//Convert byte to ubyte
				n = ((n >>> 4) & 0xF) * 16 + (n & 0xF);
				out.write(n);
			}
		}

		public void write(byte[] b, int off, int len) throws IOException {
			for (int i = off; i < off + len; i++) {
				int n = b[i];
				n = ((n >>> 4) & 0xF) * 16 + (n & 0xF);
				out.write(n);
			}
		}
	} //End of class Writer2Stream
%>

<%
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)){
		response.sendRedirect((String)request.getAttribute("Host")+admApli.Configuracion.getString("DEFAULT_CONTEXT")+"/signon/login.do");
	}

	int idOrg=Integer.parseInt(request.getParameter("idOrg"));
	String tipo=request.getParameter("tipo");
	String camino="/web/tomcat5/logs/creditos/";
	if("procesados".equals(tipo)){
		camino+="Procesados/";
	}
	if("logs".equals(tipo)){
		camino+="logs/";
	}
	if("auditorias".equals(tipo)){
		camino+="auditorias/";
	}
	if("fallados".equals(tipo)){
		camino+="Fallados/";
	}	
	camino+=idOrg+"/"+request.getParameter("file");
	out.println(camino);
	File f = new File(camino);
	if (f.exists() && f.canRead()) {
		if(request.getParameter("download")==null)
		{
			String mimeType = getMimeType(f.getName());
			response.setContentType(mimeType);
			if (mimeType.equals("text/plain")) {
				response.setHeader("Content-Disposition", "inline;filename=\"temp.txt\"");
			}
			else {
				response.setHeader("Content-Disposition", "inline;filename=\""+ f.getName() + "\"");
			}
		}
		else
		{
			response.setContentType("application/octet-stream");
			response.setHeader("Content-Disposition", "attachment;filename=\"" + f.getName()+ "\"");
		}
        BufferedInputStream fileInput = new BufferedInputStream(new FileInputStream(f));
		byte buffer[] = new byte[8 * 1024];
        out.clearBuffer();
        OutputStream out_s = new Writer2Stream(out);
        copyStreamsWithoutClose(fileInput, out_s, buffer);
        fileInput.close();
        out_s.flush();
    }
	else {
		out.println("no existe");
	}
%>	