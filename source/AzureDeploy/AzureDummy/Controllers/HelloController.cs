using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AzureDummy.Controllers
{
    public class HelloController : Controller
    {
        public ActionResult Index()
        {
            return Content("World 4");
        }
    }
}
