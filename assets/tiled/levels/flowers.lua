return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "2021.03.23",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 160,
  height = 32,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 19,
  nextobjectid = 300,
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "imagelayer",
      image = "flowers/obj0012.png",
      id = 11,
      name = "Image Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 16,
      offsety = 10,
      parallaxx = 1,
      parallaxy = 1,
      properties = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 13,
      name = "grounds",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 124,
          name = "groundB",
          type = "",
          shape = "polygon",
          x = -156,
          y = 448,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 68, y = 16 },
            { x = 68, y = 32 },
            { x = 0, y = 16 }
          },
          properties = {}
        },
        {
          id = 276,
          name = "groundB",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 488,
          width = 2528,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 277,
          name = "groundB",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 0,
          width = 16,
          height = 504,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 278,
          name = "groundB",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 0,
          width = 2528,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 279,
          name = "groundB",
          type = "",
          shape = "rectangle",
          x = 2544,
          y = 0,
          width = 16,
          height = 504,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 280,
          name = "groundB",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 400,
          width = 2528,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 8,
      name = "sensors",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 232,
          name = "ladder",
          type = "",
          shape = "rectangle",
          x = -296,
          y = 188,
          width = 8,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 282,
          name = "exit",
          type = "",
          shape = "rectangle",
          x = 2512,
          y = 276,
          width = 31,
          height = 124,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 18,
      name = "collectibles",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 275,
          name = "c01",
          type = "",
          shape = "polygon",
          x = 232,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 8, y = 0 },
            { x = 0, y = -8 },
            { x = -8, y = 0 },
            { x = 0, y = 8 },
            { x = 8, y = 0 }
          },
          properties = {}
        },
        {
          id = 283,
          name = "c01",
          type = "",
          shape = "polygon",
          x = 248,
          y = 380,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 8, y = 0 },
            { x = 0, y = -8 },
            { x = -8, y = 0 },
            { x = 0, y = 8 },
            { x = 8, y = 0 }
          },
          properties = {}
        },
        {
          id = 284,
          name = "c01",
          type = "",
          shape = "polygon",
          x = 264,
          y = 372,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 8, y = 0 },
            { x = 0, y = -8 },
            { x = -8, y = 0 },
            { x = 0, y = 8 },
            { x = 8, y = 0 }
          },
          properties = {}
        },
        {
          id = 285,
          name = "c01",
          type = "",
          shape = "polygon",
          x = 280,
          y = 380,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 8, y = 0 },
            { x = 0, y = -8 },
            { x = -8, y = 0 },
            { x = 0, y = 8 },
            { x = 8, y = 0 }
          },
          properties = {}
        },
        {
          id = 286,
          name = "c01",
          type = "",
          shape = "polygon",
          x = 296,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 8, y = 0 },
            { x = 0, y = -8 },
            { x = -8, y = 0 },
            { x = 0, y = 8 },
            { x = 8, y = 0 }
          },
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 17,
      name = "ladders",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 231,
          name = "ladder",
          type = "",
          shape = "rectangle",
          x = -304,
          y = 188,
          width = 24,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 16,
      name = "ptpfs",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 185,
          name = "ptpf",
          type = "",
          shape = "polygon",
          x = -228,
          y = 420,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = -4 },
            { x = 68, y = -16 },
            { x = 144, y = -4 },
            { x = 144, y = 1 },
            { x = 68, y = -11 },
            { x = 0, y = 1 }
          },
          properties = {}
        },
        {
          id = 269,
          name = "ptpf",
          type = "",
          shape = "rectangle",
          x = -160,
          y = 356,
          width = 60,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "mvpfs",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 70,
          name = "mvpf_S164",
          type = "",
          shape = "rectangle",
          x = -160,
          y = 308,
          width = 64,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 14,
      name = "playable",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 146,
          name = "walkerA",
          type = "",
          shape = "ellipse",
          x = 1524,
          y = 344,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 147,
          name = "walkerA",
          type = "",
          shape = "ellipse",
          x = 1852,
          y = 340,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 149,
          name = "walkerA",
          type = "",
          shape = "ellipse",
          x = 2228,
          y = 344,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 288,
          name = "walkerA",
          type = "",
          shape = "ellipse",
          x = 580,
          y = 340,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 290,
          name = "friendlyflyerB",
          type = "",
          shape = "ellipse",
          x = 344,
          y = 272,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 291,
          name = "friendlyflyerB",
          type = "",
          shape = "ellipse",
          x = 1240,
          y = 264,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 292,
          name = "friendlyflyerA",
          type = "",
          shape = "ellipse",
          x = 2024,
          y = 268,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 293,
          name = "friendlyflyerA",
          type = "",
          shape = "ellipse",
          x = 816,
          y = 256,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 294,
          name = "friendlyflyerA",
          type = "",
          shape = "ellipse",
          x = 1372,
          y = 268,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 295,
          name = "walkerBossA",
          type = "",
          shape = "ellipse",
          x = 2340,
          y = 208,
          width = 131,
          height = 164,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 299,
          name = "player1",
          type = "",
          shape = "ellipse",
          x = 32,
          y = 332,
          width = 51,
          height = 48,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 7,
      name = "fg",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {}
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 10,
      name = "test",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 87,
          name = "player1",
          type = "",
          shape = "ellipse",
          x = 224,
          y = 580,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 221,
          name = "player1j",
          type = "",
          shape = "ellipse",
          x = 92,
          y = 568,
          width = 43,
          height = 60,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 223,
          name = "player1",
          type = "",
          shape = "ellipse",
          x = 676,
          y = 592,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 265,
          name = "player1",
          type = "",
          shape = "ellipse",
          x = 384,
          y = 588,
          width = 43,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 266,
          name = "player1j",
          type = "",
          shape = "ellipse",
          x = 528,
          y = 572,
          width = 43,
          height = 60,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}