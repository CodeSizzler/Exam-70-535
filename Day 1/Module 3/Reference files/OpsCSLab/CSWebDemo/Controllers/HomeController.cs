using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CSWebDemo.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult Exception() {
            throw new Exception("This doesn't work!");

            return View();
        }

        public ActionResult Informational()
        {
            System.Diagnostics.Trace.WriteLine("Informational action logged from OpsCSLab App");
            return View();
        }

    }
}