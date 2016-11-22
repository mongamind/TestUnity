# TestUnity
 this project was created for my learning of Unity Shader,and all codes are knocked with the help of \<Untiy Shader 入门精要> by 冯乐乐, it is a wonderful book for who is newcomer to Unity.

###/Assert/Shader/

* 漫反射概念
VertexLevelDiffuse.shader     顶点漫反射
FrameLevelDiffuse.shader      片元漫反射
HalfFrameLevelDiffuse.shader  片元半\*\*漫反射

* 全反射概念
VertexLevelSpecular.shader    顶点全反射
FragmentLevelSpecular.shader	片元全反射
HalfFragmentLevelSpecular.shader  片元半\*\*全反射

* 复杂光照(多光源)
ForwarRendering.shader        前向光照渲染模式,效果最好,但是每个灯光都会执行一个Pass,多光源会导致效率变得很低.

* 纹理概念
SingleTexture.shader          基础纹理
NormalMapTangentSpace.shader  法线纹理

* 透明度处理
AlphaBlend.shader             混合式透明度处理.
AlphaBlendBothSides.shader    双面混合式透明度处理.
AlphaBlendZWrite.shader	      混合式透明度+深度写入,实现模型内不透明,但是可以穿透模型看到场景物体.
AlphaTest.shader              深度测试透明度处理,主要是通过判断片段alpha通道,高于某值则写入深度缓冲区.并开启深度测试,从而可以丢弃后方片元.

* 阴影处理
Shadow.shader                 普通无透明阴影.
ShadowAlphaTest.shader        深度测试透明度阴影.
ShadowAlphaBlend.shader       混合透明度阴影.



