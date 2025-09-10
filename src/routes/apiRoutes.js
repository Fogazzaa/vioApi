const router = require("express").Router();
const verifyJWT = require("../services/verifyJWT")

const userController = require("../controllers/userController");
const eventoController = require("../controllers/eventoController");
const compraController = require("../controllers/compraController");
const orgController = require("../controllers/orgController");
const ingController = require("../controllers/ingController");

const upload = require("../services/upload")

router.post("/user", userController.createUser);
router.get("/user", verifyJWT, userController.getAllUsers);
router.put("/user", verifyJWT, userController.updateUser);
router.delete("/user/:id_usuario", verifyJWT, userController.deleteUser);
router.post("/login", userController.loginUser);

router.post("/org", verifyJWT, orgController.createOrg);
router.get("/org", verifyJWT, orgController.getAllOrgs);
router.put("/org", verifyJWT, orgController.updateOrg);
router.delete("/org/:id_organizador", verifyJWT, orgController.deleteOrg);

router.post("/evento", upload.single("imagem"), eventoController.createEvento);
router.get("/evento/imagem/:id", eventoController.getImagemEvento)
router.get("/eventos", eventoController.getAllEventos);
router.get("/evento/data", verifyJWT, eventoController.getEventosPorData);
router.get("/evento/:data", verifyJWT, eventoController.getEventosPorData7Dias);
router.put("/evento", verifyJWT, eventoController.updateEvento);
router.delete("/evento/:id_evento", verifyJWT, eventoController.deleteEvento);

router.post("/ing", verifyJWT, ingController.createIng);
router.get("/ing", verifyJWT, ingController.getAllIngs);
router.put("/ing", verifyJWT, ingController.updateIng);
router.delete("/ing/:id_ingresso", verifyJWT, ingController.deleteIng);
router.get("/ing/evento/:id_evento", verifyJWT, ingController.getByIdEvento);

router.post("/compraSimples", verifyJWT, compraController.registrarCompraSimples);
router.post("/compra", verifyJWT, compraController.registrarCompra);

module.exports = router;
