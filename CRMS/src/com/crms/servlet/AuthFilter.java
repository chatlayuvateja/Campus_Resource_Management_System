package com.crms.servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebFilter("/*")
public class AuthFilter implements Filter {

    /* Pages that every logged-in user can access regardless of role */
    private static final Set<String> ALL_ROLES_PAGES = new HashSet<>(Arrays.asList(
        "dashboard.jsp",
        "notifications.jsp",
        "maintainance.jsp",   // all roles can submit/view maintenance
        "announcements.jsp"   // all roles can view; form is hidden in JSP for non-admin/faculty
    ));

    /* Pages that specific roles can access */
    private static final Map<String, List<String>> PAGE_ROLES = new HashMap<>();

    static {
        PAGE_ROLES.put("bookings.jsp",          Arrays.asList("student","faculty","warden","librarian","labtech"));
        PAGE_ROLES.put("library.jsp",           Arrays.asList("student","faculty","librarian","admin"));
        PAGE_ROLES.put("equipment.jsp",         Arrays.asList("student","faculty","labtech","warden","librarian"));
        PAGE_ROLES.put("complaints.jsp",        Arrays.asList("student","faculty","warden","labtech","librarian"));
        PAGE_ROLES.put("hostel.jsp",            Arrays.asList("admin","warden"));
        PAGE_ROLES.put("reports.jsp",           Arrays.asList("admin"));
        PAGE_ROLES.put("admin.jsp",             Arrays.asList("admin"));
        PAGE_ROLES.put("resource_register.jsp", Arrays.asList("admin"));
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req = (HttpServletRequest)  request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();

        // Public pages – no login required
        boolean publicPage =
            uri.endsWith("login.html")    ||
            uri.endsWith("login.jsp")     ||
            uri.endsWith("register.jsp")  ||
            uri.endsWith("LoginServlet")  ||
            uri.endsWith("RegisterServlet") ||
            uri.contains(".css")          ||
            uri.contains(".js")           ||
            uri.contains(".png")          ||
            uri.contains(".ico");

        if (publicPage) { chain.doFilter(request, response); return; }

        HttpSession session = req.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // Not logged in
        if (role == null) {
            res.sendRedirect(req.getContextPath() + "/login.html");
            return;
        }

        // Get page name from URI
        String page = uri.substring(uri.lastIndexOf('/') + 1);

        // All-roles pages: any logged-in user is fine
        if (ALL_ROLES_PAGES.contains(page)) {
            chain.doFilter(request, response);
            return;
        }

        // Admin can access everything except student-only pages
        if ("admin".equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        // Check specific role permissions
        if (PAGE_ROLES.containsKey(page)) {
            List<String> allowed = PAGE_ROLES.get(page);
            if (!allowed.contains(role)) {
                res.sendRedirect(req.getContextPath() + "/dashboard.jsp?error=unauthorized");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    public void init(FilterConfig config) {}
    public void destroy() {}
}
