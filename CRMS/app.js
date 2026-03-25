(function () {

  const PUBLIC_PAGES = ['login.html', 'index.html'];

  const username = sessionStorage.getItem('crms_username');
  const role = sessionStorage.getItem('crms_role');

  function currentPage() {
    const path = window.location.pathname;
    return path.substring(path.lastIndexOf('/') + 1);
  }

  /* ===== Login Protection ===== */
  function enforceLogin() {
    const page = currentPage();
    if (!PUBLIC_PAGES.includes(page) && (!username || !role)) {
      window.location.href = 'login.html';
    }
  }

  /* ===== Role-based Access ===== */
  const ROLE_PAGES = {
    student: [
      "dashboard.html",
      "bookings.html",
      "library.html",
      "equipment.html",
      "complaints.html",
      "notifications.html"
    ],
    faculty: [
      "dashboard.html",
      "bookings.html",
      "library.html",
      "equipment.html",
      "complaints.html",
      "announcements.html",
      "notifications.html"
    ],
    librarian: [
      "dashboard.html",
      "library.html",
      "notifications.html"
    ],
    labtech: [
      "dashboard.html",
      "equipment.html",
      "bookings.html",
      "notifications.html"
    ],
    warden: [
      "dashboard.html",
      "hostel.html",
      "complaints.html",
      "notifications.html"
    ],
    admin: [
      "dashboard.html",
      "bookings.html",
      "library.html",
      "equipment.html",
      "hostel.html",
      "complaints.html",
      "announcements.html",
      "notifications.html"
    ]
  };

  function enforceRoleAccess() {
    const page = currentPage();
    if (!role) return;

    const allowedPages = ROLE_PAGES[role.toLowerCase()] || [];

    if (!allowedPages.includes(page) && !PUBLIC_PAGES.includes(page)) {
      alert("Access denied for your role.");
      window.location.href = "dashboard.html";
    }
  }

  /* ===== Logout ===== */
  window.crmsLogout = function () {
    sessionStorage.clear();
    window.location.href = 'login.html';
  };

  /* ===== Redirect Logged User ===== */
  function redirectFromLoginIfNeeded() {
    const page = currentPage();
    if ((page === 'login.html' || page === 'index.html') && username && role) {
      window.location.href = 'dashboard.html';
    }
  }

  enforceLogin();
  enforceRoleAccess();
  redirectFromLoginIfNeeded();

})();
