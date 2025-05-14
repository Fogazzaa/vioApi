const router = require("express").Router();
const verifyJWT = require("../services/verifyJWT")

const userController = require("../controllers/userController");
const orgController = require("../controllers/orgController");
const eventoController = require("../controllers/eventoController");
const ingController = require("../controllers/ingController");

router.post("/user", userController.createUser);
router.get("/user", verifyJWT, userController.getAllUsers);
router.put("/user", verifyJWT, userController.updateUser);
router.delete("/user/:id_usuario", verifyJWT, userController.deleteUser);
router.post("/login", userController.loginUser);

router.post("/org", verifyJWT, orgController.createOrg);
router.get("/org", verifyJWT, orgController.getAllOrgs);
router.put("/org", verifyJWT, orgController.updateOrg);
router.delete("/org/:id_organizador", verifyJWT, orgController.deleteOrg);

router.post("/evento", verifyJWT, eventoController.createEvento);
router.get("/eventos", verifyJWT, eventoController.getAllEventos);
router.get("/evento/data", verifyJWT, eventoController.getEventosPorData);
router.get("/evento/:data", verifyJWT, eventoController.getEventosPorData7Dias);
router.put("/evento", verifyJWT, eventoController.updateEvento);
router.delete("/evento/:id_evento", verifyJWT, eventoController.deleteEvento);

router.post("/ing", verifyJWT, ingController.createIng);
router.get("/ing", verifyJWT, ingController.getAllIngs);
router.put("/ing", verifyJWT, ingController.updateIng);
router.delete("/ing/:id_ingresso", verifyJWT, ingController.deleteIng);
router.get("/ing/evento/:id_evento", verifyJWT, ingController.getByIdEvento);

module.exports = router;
